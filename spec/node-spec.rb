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

require 'boxgrinder-node/node'

module BoxGrinder
  module Node
    describe Node do
      before(:each) do
        log = LogHelper.new(:level => :trace, :type => :stdout)

        @config = mock(NodeConfig, OpenCascade.new(
            :rest_server_host => 'myhost',
            :rest_server_port => 1099,
            :name => 'node-name-abcdef',
            :timeout => 1000,
            :os_name => 'fedora',
            :os_version => '14')
        )
        @config.stub!(:read_config_file!)
        @config.stub!(:to_yaml).and_return('NodeConfig content')

        node_validator = mock(NodeValidator)
        node_validator.stub!(:validate)

        NodeValidator.stub!(:new).and_return(node_validator)

        @node = Node.new(:config => @config, :log => log)
      end

      describe ".wait_for_confirmation" do
        it "should receive valid register confirmation" do
          topic = mock(TorqueBox::Messaging::Topic)
          topic.should_receive(:receive).with(:selector => "node = 'node-name-abcdef' and operation = 'register'", :timeout => 1000).and_return('ok')

          TorqueBox::Messaging::Topic.should_receive(:new).with("/topics/boxgrinder_rest/node", :naming_host => "myhost", :naming_port => 1099).and_return(topic)

          @node.wait_for_confirmation(:register)
        end

        it "should receive timeout" do
          topic = mock(TorqueBox::Messaging::Topic)
          topic.should_receive(:receive).with(:selector => "node = 'node-name-abcdef' and operation = 'register'", :timeout => 1000).and_return(nil)

          TorqueBox::Messaging::Topic.should_receive(:new).with("/topics/boxgrinder_rest/node", :naming_host => "myhost", :naming_port => 1099).and_return(topic)

          @node.should_receive(:abort)
          @node.wait_for_confirmation(:register)
        end

        it "should receive invalid register confirmation" do
          topic = mock(TorqueBox::Messaging::Topic)
          topic.should_receive(:receive).with(:selector => "node = 'node-name-abcdef' and operation = 'register'", :timeout => 1000).and_return('abcdef')

          TorqueBox::Messaging::Topic.should_receive(:new).with("/topics/boxgrinder_rest/node", :naming_host => "myhost", :naming_port => 1099).and_return(topic)

          @node.should_receive(:abort)
          @node.wait_for_confirmation(:register)
        end
      end

      describe ".bind_consumers" do
        it "should bind queue consumers" do
          dispatcher = mock(TorqueBox::Messaging::Dispatcher)

          content = mock('abc') # lambda { }
          #content.should_receive(:map)

          #@node.should_receive(:map).with(BuildImageConsumer, "/queues/boxgrinder_rest/image", :filter => "os_name = 'fedora'")

          TorqueBox::Messaging::Dispatcher.should_receive(:new).with(:naming_host => "myhost", :naming_port => 1099).and_yield(content).and_return(dispatcher)

          @node.bind_consumers.should == dispatcher
        end
      end
    end
  end
end