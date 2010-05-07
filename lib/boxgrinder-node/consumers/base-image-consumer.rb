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

require 'boxgrinder-core/models/appliance-config'
require 'boxgrinder-core/helpers/queue-helper'
require 'boxgrinder-core/helpers/exec-helper'
require 'boxgrinder-core/models/task'

module BoxGrinder
  module Node
    class BaseImageConsumer
      def build( definition_file, platform = nil )
        appliance_config = YAML.load_file( definition_file ).init_arch

        @log.info "Building#{platform.nil? ? "" : " #{platform}"} image for #{appliance_config.name} appliance, #{appliance_config.hardware.arch} arch..."

        platform_cmd = platform.nil? ? "" : "-p #{platform}"

        begin
          @exec_helper.execute "cd #{@node_config.build_location} && boxgrinder-build --trace build #{definition_file} #{platform_cmd}"
          @log.info "Image for#{platform.nil? ? "" : " #{platform}"} #{appliance_config.name} appliance, #{appliance_config.hardware.arch} arch was built successfully."
          return true
        rescue
          @log.error "An error occurred while building image for#{platform.nil? ? "" : " #{platform}"} '#{appliance_config.name}' appliance. Check logs for more info."
          return false
        end
      end

      def store_definition( appliance_config )
        @log.debug "Storing definition file for '#{appliance_config.name}' appliance..."
        @log.trace appliance_config.to_yaml

        appliances_dir  = "#{@node_config.build_location}/appliances"
        file            = "#{appliances_dir}/#{appliance_config.name}.appl"

        FileUtils.mkdir_p(appliances_dir)
        File.open(file, 'w') { |f| f.write(appliance_config.to_yaml) }

        @log.debug "Definition stored in '#{file}' file."

        file
      end

      def definition_location( appliance_name )
        "#{@node_config.build_location}/appliances/#{appliance_name}.appl"
      end

      def task_received( payload )
        @log.info "Received new image task."
        @log.trace "Message:\n#{payload.to_yaml}"
      end
    end
  end
end