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
    class DeliverImageConsumer < BaseImageConsumer
      def init( options = {} )
        @log              = options[:log]           || Node.log
        @node_config      = options[:node_config]   || Node.config
        @queue_helper     = options[:queue_helper]  || QueueHelper.new( :host => @node_config.rest_server_address, :port => 1099, :log => @log )
        @exec_helper      = options[:exec_helper]   || ExecHelper.new( :log => @log )
      end

      def on_object(payload)
        init

        task_received( payload )

        name         = payload.data[:name]
        platform     = payload.data[:platform]
        image_id     = payload.data[:image_id]
        type         = payload.data[:type]

        platform_cmd = platform.nil? ? "" : "-p #{platform}"

        @log.info "Delivering image for #{name} appliance, using #{type} type..."
        @queue_helper.client( :host => @node_config.rest_server_address ) { |client| client.send(IMAGE_MANAGEMENT_QUEUE, :object => {:id => image_id, :status  => :delivering } ) }

        begin
          @exec_helper.execute "cd #{@node_config.build_location} && boxgrinder-build --trace build #{definition_location( name )} #{platform_cmd} -d #{type}"
          @log.info "Image delivered."
          @queue_helper.client( :host => @node_config.rest_server_address ) { |client| client.send(IMAGE_MANAGEMENT_QUEUE, :object => {:id => image_id, :status  => :delivered } ) }
        rescue => e
          @log.error "Image not delivered. See logs for more information."
          @queue_helper.client( :host => @node_config.rest_server_address ) { |client| client.send(IMAGE_MANAGEMENT_QUEUE, :object => {:id => image_id, :status  => :error } ) }
        end
      end
    end
  end
end