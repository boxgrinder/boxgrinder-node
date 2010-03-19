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

module BoxGrinder
  module Node
    class BuildPackageCommand < BaseCommand
      def after_initialize
        @appliance_config = @task.data[:appliance_config].init
        @package_format   = @task.data[:package_format]
        @image_format     = @task.data[:image_format]
        @package_id       = @task.data[:package_id]
      end

      def execute
        remove_old_package

        @log.info "Building '#{@package_format}' package for '#{@appliance_config.name}' image in '#{@image_format}' format..."

        case @package_format
          when 'TGZ' then
            command = "appliance:#{@appliance_config.name}:package:#{@image_format.downcase}:tgz"
          when 'ZIP' then
            command = "appliance:#{@appliance_config.name}:package:#{@image_format.downcase}:zip"
          else
            @log.error "Not valid format: '#{@package_format}'. It should never happen!"
            return
        end

        @queue_helper.enqueue( PACKAGE_MANAGEMENT_QUEUE, { :id => @package_id, :status => :building } )

        begin
          @exec_helper.execute "cd #{@config.build_location} && boxgrinder #{command}"

          @log.info "'#{@package_format}' package for '#{@appliance_config.name}' image in '#{@image_format}' format was built successfully."
          @queue_helper.enqueue( PACKAGE_MANAGEMENT_QUEUE, { :id => @package_id, :status  => :built } )
        rescue
          @log.error "An error occurred while building '#{@package_format}' package for '#{@appliance_config.name}' image in '#{@image_format}'. Check logs for more info."
          @queue_helper.enqueue( PACKAGE_MANAGEMENT_QUEUE, { :id => @package_id, :status  => :error } )
        end
      end

      def remove_old_package
        @log.debug "Removing old package..."
        @exec_helper.execute "cd #{@config.build_location} && rm -rf #{@appliance_config.path.file.package[@image_format.downcase.to_sym][@package_format.downcase.to_sym]}"
        @log.debug "Old package removed."
      end
    end
  end
end