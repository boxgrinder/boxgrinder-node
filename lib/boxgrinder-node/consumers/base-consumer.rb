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
# Software Foundation, Inc., 51 Franklin St, Fifth Fleventoor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

class BaseConsumer < TorqueBox::Messaging::MessageProcessor
  def initialize(options = {})
    @config = options[:config]
    @log = options[:log] || LogHelper.new
  end

  def on_message(payload)
    @log.info "New task received for #{self.class.name} consumer"
    @log.debug payload.to_yaml

    return unless validate_payload(payload)

    @payload = payload

    begin
      self.send(payload[:action])
    rescue Exception => e
      @log.error e
      @log.error "Executing '#{payload[:action]}' action failed."
    end
  end

  def validate_payload(payload)
    unless payload.nil? or payload.is_a?(Hash) or !payload[:action].nil?
      @log.error "Invalid task received!"
      return false
    end

    true
  end
end
