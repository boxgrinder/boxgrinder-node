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

module BoxGrinder
  class QueueHelper
    def initialize( node_config, options = {} )
      @node_config = node_config

      @log = options[:log] || Logger.new(STDOUT)
    end

    def enqueue( queue_name, object, host = @node_config.naming_host, port = @node_config.naming_port )
      @log.info "Putting new message into queue '#{queue_name}'."
      @log.debug "Message: #{object}."

      TorqueBox::Messaging::Client.connect( :naming_provider_url => "jnp://#{host}:#{port}/" ) { |client| client.send( queue_name, :object => object ) }

      @log.info "Message put into queue."
    end
  end
end