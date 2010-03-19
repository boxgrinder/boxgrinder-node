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

require 'boxgrinder-node/helpers/queue-helper'
require 'boxgrinder-core/helpers/exec-helper'
require 'logger'

module BoxGrinder
  module Node
    class BaseCommand
      def initialize( task, config, options = {} )
        @task             = task
        @config           = config

        @log              = options[:log]           || Logger.new(STDOUT)
        @queue_helper     = options[:queue_helper]  || QueueHelper.new( @config, :log => @log )
        @exec_helper      = options[:exec_helper]   || ExecHelper.new( :log => @log )

        after_initialize
      end

      def after_initialize
      end
    end
  end
end