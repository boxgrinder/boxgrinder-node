# JBoss, Home of Professional Open Source
# Copyright 2009, Red Hat Middleware LLC, and individual contributors
# by the @authors tag. See the copyright.txt in the distribution for a
# full listing of individual contributors.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
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

require 'boxgrinder-node/defaults'
require 'rbconfig'

module BoxGrinder
  module Node
    class NodeConfig
      def initialize
        config_file = ENV['BG_CONFIG_FILE'] || "#{ENV['HOME']}/.boxgrinder/config"

        if File.exists?( config_file )
          config = YAML.load_file( config_file )

          unless config['jms'].nil?
            @naming_host = config['jms']['naming_host']
            @naming_port = config['jms']['naming_port']
          end
        end

        @naming_host ||= DEFAULT_NAMING_HOST
        @naming_port ||= DEFAULT_NAMING_PORT

        @address      = get_current_ip
        @arch         = RbConfig::CONFIG['host_cpu']
      end

      def get_current_ip
        `ip addr list eth0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1`.strip
      end

      attr_reader :address
      attr_reader :naming_host
      attr_reader :naming_port
      attr_reader :arch
    end
  end
end