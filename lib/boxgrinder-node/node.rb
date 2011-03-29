#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
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
require 'torquebox-messaging'
require 'torquebox-messaging-container'

require 'boxgrinder-core/helpers/log-helper'

require 'boxgrinder-node/models/node-config'
require 'boxgrinder-node/consumers/image-consumer'
require 'boxgrinder-node/validators/node-validator'

module BoxGrinder
  module Node
    class Node
      IMAGE_MANAGEMENT_QUEUE = '/queues/boxgrinder_rest/manage/image'
      NODE_MANAGEMENT_QUEUE = '/queues/boxgrinder_rest/manage/node'
      NODE_MANAGEMENT_TOPIC = '/topics/boxgrinder_rest/node'

      def initialize(options = {})
        @config = options[:config] || NodeConfig.new
        @log = options[:log] || LogHelper.new(:location => @config.log_file, :level => @config.log_level)

        NodeValidator.new(@config, :log => @log).validate
        @config.read_config_file!

        @log.trace "NodeConfig:\n#{@config.to_yaml}"
      end

      def start
        @log.info "Starting new BoxGrinder Node..."

        t = Thread.new { wait_for_confirmation(:register) }
        sleep 1
        register
        t.join

        dispatcher = bind_consumers

        @log.trace "Starting messaging dispatcher..."

        begin
          dispatcher.start
        rescue => e
          @log.fatal e.message
          @log.fatal "Couldn't start messaging dispatcher, aborting."
          abort
        end

        @log.trace "Messaging dispatcher started."
        @log.info "BoxGrinder Node is started and waiting for tasks."

        wait_for_break

        begin
          dispatcher.stop
        rescue => e
          @log.warn e.message
          @log.warn "Couldn't stop messaging dispatcher."
        end

        t = Thread.new { wait_for_confirmation(:unregister) }
        sleep 1
        unregister
        t.join

        exit # clean shutdown
      end

      def register
        @log.info "Registering node with BoxGrinder REST server..."
        @log.trace "Connecting to BoxGrinder REST server: address: #{@config.rest_server_host}, port: #{@config.rest_server_port}..."

        begin
          queue = TorqueBox::Messaging::Queue.new(NODE_MANAGEMENT_QUEUE, :naming_host => @config.rest_server_host, :naming_port => @config.rest_server_port)
          queue.publish({
                            :action => :register,
                            :node => {
                                :name => @config.name,
                                :address => @config.address
                            }
                        })
        rescue => e
          @log.error e
        end

        @log.debug "Registration for node '#{@config.name}' sent."
      end

      def unregister
        @log.info "Un-registering node with BoxGrinder REST server..."

        begin
          queue = TorqueBox::Messaging::Queue.new(NODE_MANAGEMENT_QUEUE, :naming_host => @config.rest_server_host, :naming_port => @config.rest_server_port)
          queue.publish({
                            :action => :unregister,
                            :node => {
                                :name => @config.name
                            }
                        })


        rescue => e
          @log.error e
        end

        @log.info "Node unregistered."
      end

      def wait_for_confirmation(operation)
        @log.info "Waiting for confirmation for #{operation} action..."

        topic = TorqueBox::Messaging::Topic.new(NODE_MANAGEMENT_TOPIC, :naming_host => @config.rest_server_host, :naming_port => @config.rest_server_port)
        response = topic.receive(:selector => "node = '#{@config.name}' and operation = '#{operation.to_s}'", :timeout => @config.timeout)

        if response.nil? or !response.is_a?(String) or response != 'ok'
          @log.fatal "No or invalid confirmation received, aborting."
          abort
        end

        @log.info "Operation #{operation} confirmed."
      end

      def bind_consumers
        @log.debug "Binding queue consumers..."

        config = @config
        log = @log

        dispatcher = TorqueBox::Messaging::Dispatcher.new(:naming_host => @config.rest_server_host, :naming_port => @config.rest_server_port) do
          map ImageConsumer, "/queues/boxgrinder_rest/image",
              :filter => "#{config.is64bit? ? "arch = 'i386' OR arch = 'x86_64'" : "arch = 'i386'"}",
              :config => {:log => log, :config => config}
        end

        @log.debug "Consumers bound."

        dispatcher
      end

      def wait_for_break
        keep_running = true

        ['TERM', 'INT'].each do |signal|
          Signal.trap(signal) do
            @log.info "Shutting down BoxGrinder node..."
            keep_running = false
          end
        end

        while (keep_running)
          sleep(1)
        end
      end

    end
  end
end
