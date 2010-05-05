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
require 'torquebox-messaging-client'
require 'logger'

module BoxGrinder
  class QueueHelper
    def initialize(config, options = {})
      @config = config
      @log    = options[:log] || Logger.new(STDOUT)
    end

    def send(queue_name, object, opts = {})
      host    = opts[:host] || @config.rest_server_address
      port    = opts[:port] || @config.naming_port

      type    = object.is_a?(String) ? :text : :object

      type    = opts[:type] unless opts[:type].nil?

      @log.debug "Putting new message into queue '#{queue_name}'."
      @log.trace "Message:\n#{object.to_yaml}"

      TorqueBox::Messaging::Client.connect(:naming_provider_url => "jnp://#{host}:#{port}/") { |client| client.send(queue_name, type => object) }

      @log.debug "Message put into queue."
    end

    def receive(queue_name, opts = {})
      filter  = opts[:filter]
      host    = opts[:host] || @config.rest_server_address
      port    = opts[:port] || @config.naming_port
      raw     = opts[:raw]  || false

      @log.debug "Waiting for message in queue '#{queue_name}' using filter: '#{filter}'."
      TorqueBox::Messaging::Client.connect(:naming_provider_url => "jnp://#{host}:#{port}/") { |client| return client.receive(queue_name, :filter => filter, :raw => raw) }
    end

    def client(opts = {})
      host          = opts[:host] || @config.rest_server_address
      port          = opts[:port] || @config.naming_port

      @log.debug "Creating TB messaging client..."
      TorqueBox::Messaging::Client.connect(:naming_provider_url => "jnp://#{host}:#{port}/") { |client| yield client }
    end
  end
end