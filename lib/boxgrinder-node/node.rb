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

require 'rubygems'
require 'torquebox-messaging-container'
require 'boxgrinder-core/helpers/log-helper'
require 'boxgrinder-node/models/node-config'
require 'boxgrinder-node/consumers/build-image-consumer'
require 'boxgrinder-node/consumers/management-consumer'
require 'boxgrinder-node/validators/node-config-validator'
require 'boxgrinder-node/defaults'

module BoxGrinder
  module Node
    class Node
      def initialize
        config_location = ENV['BG_CONFIG_FILE'] || DEFAULT_NODE_CONFIG_LOCATION

        NodeConfigValidator.new.validate(config_location)

        @@config      = NodeConfig.new(config_location)
        @config       = Node.config

        @@log         = LogHelper.new(@config.log_location)
        @log          = Node.log

        @queue_helper = QueueHelper.new(@config, :log => @log)
      end

      def self.config
        @@config
      end

      def self.log
        @@log
      end

      def start
        register
        listen
      end

      def register
        @log.info "Registering node with BoxGrinder REST server..."
        @log.trace "BoxGrinder REST server address: #{@config.rest_server_address}"

        response = nil

        begin
          @queue_helper.client do |client|
            response = client.send_and_receive(
                    NODE_MANAGEMENT_QUEUE,
                    :object => {
                            :action => :register,
                            :node => {
                                    :address    => @config.address,
                                    :arch       => @config.arch,
                                    :os_name    => @config.os_name,
                                    :os_version => @config.os_version
                            }, :timeout => 0
                    }
            )
          end
        rescue => e
          @log.error e
        end

        if response.nil? or !response.is_a?(String)
          @log.fatal "Couldn't register node in BoxGrinder REST server, aborting."
          abort
        end

        @config.name = response

        @log.info "Node registered under '#{@config.name}' name."
      end

      # TODO get rid of class variables!
      def listen
        @log.info "Starting BoxGrinder Node..."
        @log.trace "NodeConfig:\n#{@config.to_yaml}"

        config = @config

        begin
          container = TorqueBox::Messaging::Container.new {
            naming_provider_url "jnp://#{config.rest_server_address}:#{config.naming_port}/"

            consumers {
              map BuildImageConsumer, "/queues/boxgrinder/image/create", "os_name = '#{config.os_name}' AND os_version = '#{config.os_version}' AND arch = '#{config.arch}'"
            #map ConvertImageConsumer, "/queues/boxgrinder/image/convert", "node = '#{config.name}'"
            #map DeliverImageConsumer, "/queues/boxgrinder/image/deliver", "node = '#{config.name}'"
            }
          }
        rescue => e
          @log.error e
          @log.fatal "Couldn't bind to queues. See log for more information, aborting."
          abort
        end

        container.start

        @log.info "BoxGrinder Node is started and waiting for tasks."
        container.wait_until('INT')
        container.stop
        @log.info "Shutting down BoxGrinder Node."
      end
    end
  end
end
