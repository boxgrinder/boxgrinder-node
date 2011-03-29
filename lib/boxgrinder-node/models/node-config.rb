#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'boxgrinder-core/helpers/log-helper'
require 'hashery/opencascade'
require 'rbconfig'
require 'zlib'

module BoxGrinder
  module Node
    class NodeConfig < OpenCascade
      def initialize
        super({})

        address = get_current_ip
        arch = RbConfig::CONFIG['host_cpu'].eql?('amd64') ? 'x86_64' : RbConfig::CONFIG['host_cpu']


        merge!(
            :rest_server_host => 'localhost',
            :rest_server_port => 1099,
            :build_path => 'build',
            :timeout => 30000, # 30 sec

            :log_level => :trace,
            :log_file => 'log/node.log',

            :config_file => ENV['BG_CONFIG_FILE'] || "#{ENV['HOME']}/.boxgrinder-node/config",

            :address => address,
            :os_name => 'unknown',
            :os_version => 'unknown',
            :arch => arch
        )

        merge!(:name => "node-#{self.address}-#{Zlib.crc32([self.address, self.arch, self.os_name, self.os_version].join).to_s(16)}")
      end

      def is64bit?
        self.arch.eql?("x86_64")
      end

      def read_config_file!
        symbolize_and_merge!(YAML.load_file(self.config_file)) if File.exists?(self.config_file)
      end

      def symbolize_and_merge!(values)
        merge!(values.inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo })
      end

      def get_current_ip
        `ip addr list eth0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1`.strip
      end
    end
  end
end