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

require 'tmpdir'
require 'yaml'
require 'boxgrinder-node/consumers/base-consumer'
require 'boxgrinder-build/appliance'

module BoxGrinder
  module Node
    class ImageConsumer < BaseConsumer
      def report_progress(event)
        @log.info "Sending '#{event}' event for image '#{@payload[:image_id]}'..."
        begin
          @queue = TorqueBox::Messaging::Queue.new('/queues/boxgrinder_rest/manage/image', :naming_host => @config.rest_server_host, :naming_port => @config.rest_server_port)
          @queue.publish(
              {
                  :action => :progress,
                  :event => event,
                  :image_id => @payload[:image_id],
                  :node => @config.name
              }
          )

          @log.debug "Event sent."
        rescue => e
          @log.error e
        end
      end

      ### Actions

      # This action creates the appliance using BoxGrinder Build
      def build
        @log.info "Building appliance for image with id '#{@payload[:image_id]}'..."
        report_progress(:build!)

        #definition = YAML.load(@payload[:definition])
        #definition_file = "#{Dir.tmpdir}/#{definition['name']}.appl"

        #File.open(definition_file, 'w') { |f| f.write(@payload[:definition]) }

        begin
          Appliance.new(@payload[:definition], Config.new, :log => @log).create

         # system "sudo boxgrinder build #{definition_file} --trace"
          #raise unless $? == 0

          @log.info "Appliance for image with id '#{@payload[:image_id]}' built."
          report_progress(:built!)
        rescue Exception => e
          @log.error e
          @log.error "Build image with id '#{@payload[:image_id]}' failed."
          report_progress(:error!)
        end
      end
    end
  end
end
