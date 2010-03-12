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
require 'boxgrinder-node/defaults'

module BoxGrinder
  module Node

    LOG         = LogHelper.new( DEFAULT_NODE_LOG_LOCATION )
    NODE_CONFIG = NodeConfig.new

    class Initializer
      def initialize
        @log = LOG
      end

      def listen
        container = TorqueBox::Messaging::Container.new {
          naming_provider_url "jnp://#{NODE_CONFIG.naming_host}:#{NODE_CONFIG.naming_port}/"

          consumers {
            map ImageConsumer, "/queues/boxgrinder/fedora/12/#{NODE_CONFIG.arch}/image"
          }
        }

        @log.info "Starting BoxGrinder Node..."
        container.start
        @log.info "BoxGrinder Node is started and waiting for tasks."
        container.wait_until( 'INT' )
        @log.info "Shutting down BoxGrinder Node."
      end
    end
  end
end
