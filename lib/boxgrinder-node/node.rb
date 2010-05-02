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
require 'boxgrinder-node/consumers/image-consumer'
require 'boxgrinder-node/consumers/package-consumer'
require 'boxgrinder-node/validators/node-config-validator'
require 'boxgrinder-node/defaults'

module BoxGrinder
  module Node
    class Node
      def initialize
        config_location = ENV['BG_CONFIG_FILE'] || DEFAULT_NODE_CONFIG_LOCATION

        NodeConfigValidator.new.validate( config_location )

        @@config      = NodeConfig.new( config_location )
        @config       = Node.config

        @@log         = LogHelper.new( @config.log_location )
        @log          = Node.log

        @queue_helper = QueueHelper.new( @config, :log => @log )
      end

      def self.config
        @@config
      end

      def self.log
        @@log
      end

      # TODO get rid of class variables!

      def listen
        container = TorqueBox::Messaging::Container.new {
          naming_provider_url "jnp://#{Node.config.rest_server_address}:#{Node.config.naming_port}/"

          consumers {
            map ImageConsumer, "/queues/boxgrinder/#{Node.config.os_name}/#{Node.config.os_version}/#{Node.config.arch}/image"
          }
        }

        @log.info "Starting BoxGrinder Node..."
        @log.debug "NodeConfig:\n#{@config.to_yaml}"

        container.start

        @log.info "Registering node with BoxGrinder REST server (#{@config.rest_server_address})..."
        @queue_helper.enqueue( NODE_MANAGEMENT_QUEUE, { :action => :register, :node => { :address => @config.address, :arch => @config.arch, :os_name => @config.os_name, :os_version => @config.os_version }} )
        @log.info "Node registered."

        @log.info "BoxGrinder Node is started and waiting for tasks."
        container.wait_until( 'INT' )
        @log.info "Shutting down BoxGrinder Node."
      end
    end
  end
end
