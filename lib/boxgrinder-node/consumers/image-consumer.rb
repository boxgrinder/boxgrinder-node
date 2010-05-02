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

require 'boxgrinder-node/commands/build-image-command'
require 'boxgrinder-core/models/appliance-config'
require 'boxgrinder-core/models/task'

module BoxGrinder
  module Node
    class ImageConsumer
      def on_object( payload )
        @task         = payload
        @log          = Node.log
        @node_config  = Node.config

        @log.info "Received new task."
        @log.debug "Message:\n#{@task.to_yaml}"

        begin
          case @task.action
            when :build then
              BuildImageCommand.new( @task, @node_config, :log => @log ).execute
            else
              raise "Not known Task action requested: #{@task.action}"
          end

          @log.info "Task handled."
        rescue => e
          @log.error e
          @log.error "An error occurred while executing task. See above for more info."
          # TODO resend information about error or put this task back into queue
        end
      end
    end
  end
end