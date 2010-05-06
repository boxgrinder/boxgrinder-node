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

require 'boxgrinder-node/consumers/base-image-consumer'

module BoxGrinder
  module Node
    class CreateImageConsumer < BaseImageConsumer
      def init( options = {} )
        @log              = options[:log]           || Node.log
        @node_config      = options[:node_config]   || Node.config
        @queue_helper     = options[:queue_helper]  || QueueHelper.new( :host => @node_config.rest_server_address, :port => 1099, :log => @log )
        @exec_helper      = options[:exec_helper]   || ExecHelper.new( :log => @log )
      end

      def on_object(payload)
        @task = payload

        init

        @appliance_config = @task.data[:appliance_config].init_arch
        @image_id         = @task.data[:image_id]

        @log.info "Received new task."
        @log.trace "Message:\n#{@task.to_yaml}"

        create
      end

      def create
        build( store_definition )
      end

      def store_definition
        @log.debug "Storing definition file for '#{@appliance_config.name}' appliance..."

        appliances_dir  = "#{@node_config.build_location}/appliances"
        file            = "#{appliances_dir}/#{@appliance_config.name}.appl"

        FileUtils.mkdir_p(appliances_dir)
        File.open(file, 'w') { |f| f.write(@appliance_config.to_yaml) }

        @log.debug "Definition stored in '#{file}' file."

        file
      end
    end
  end
end