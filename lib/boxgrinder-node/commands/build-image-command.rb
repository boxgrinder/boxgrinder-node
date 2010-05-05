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

require 'boxgrinder-node/commands/base-command'
require 'fileutils'

module BoxGrinder
  module Node
    class BuildImageCommand < BaseCommand
      def after_initialize
        @appliance_config = @task.data[:appliance_config].init_arch
        @platform         = @task.data[:platform]
        @image_id         = @task.data[:image_id]
      end

      def execute
        definition_file = store_definition

        @log.info "Building image for #{@appliance_config.name} appliance (#{@appliance_config.hardware.arch}) appliance and #{@platform} platform..."

        @queue_helper.send(IMAGE_MANAGEMENT_QUEUE, {:id => @image_id, :status => :building})

        platform = @platform.nil? ? '' : "-p #{@platform}"

        begin
          @exec_helper.execute "cd #{@config.build_location} && boxgrinder-build --trace build #{definition_file} -f #{platform}"

          @log.info "Image for '#{@appliance_config.name}' (#{@appliance_config.hardware.arch}) appliance and '#{@platform}' format was built successfully."
          @queue_helper.send(IMAGE_MANAGEMENT_QUEUE, {:id => @image_id, :status  => :built})
        rescue
          @log.error "An error occurred while building image for '#{@appliance_config.name}' (#{@appliance_config.hardware.arch}) appliance and '#{@platform}' format. Check logs for more info."
          @queue_helper.send(IMAGE_MANAGEMENT_QUEUE, {:id => @image_id, :status  => :error})
        end
      end

      def store_definition
        @log.debug "Storing definition file for '#{@appliance_config.name}' appliance..."

        appliances_dir  = "#{@config.build_location}/appliances"
        file            = "#{appliances_dir}/#{@appliance_config.name}.appl"

        FileUtils.mkdir_p(appliances_dir)
        File.open(file, 'w') { |f| f.write(@appliance_config.to_yaml) }

        @log.debug "Definition stored in '#{file}' file."

        file
      end
    end
  end
end