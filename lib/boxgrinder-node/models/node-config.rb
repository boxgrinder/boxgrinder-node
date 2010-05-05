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
      def initialize( config_file )
        @os_name        = 'unknown'
        @address        = get_current_ip
        @arch           = RbConfig::CONFIG['host_cpu']
        @build_location = Dir.pwd

        if File.exists?( config_file )
          config = YAML.load_file( config_file )

          @rest_server_address  = config['rest_server_address']
          @naming_port          = config['naming_port']
          @log_location         = config['log_location']
          @build_location       = config['build_location'] unless config['build_location'].nil?
        end

        @log_location         ||= ENV['BG_LOG_LOCATION']
        @rest_server_address  ||= DEFAULT_REST_SERVER
        @naming_port          ||= DEFAULT_NAMING_PORT
        @log_location         ||= DEFAULT_NODE_LOG_LOCATION

        if File.exists?( '/etc/redhat-release' )
          redhat_release = File.read( '/etc/redhat-release' )

          @os_name = 'rhel'   if redhat_release.match( /^Red Hat Enterprise Linux/ )
          @os_name = 'fedora' if redhat_release.match( /^Fedora/ )

          @os_version = redhat_release.scan(/\d+/).to_s
        end
      end

      def get_current_ip
        `ip addr list eth0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1`.strip
      end

      attr_reader :address
      attr_reader :rest_server_address
      attr_reader :naming_port
      attr_reader :build_location
      attr_reader :log_location
      attr_reader :arch
      attr_reader :os_name
      attr_reader :os_version
      
      attr_accessor :name
    end
  end
end