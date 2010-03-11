$: << File.join( File.dirname( __FILE__ ), 'consumers' )
$: << File.join( File.dirname( __FILE__ ), 'lib', 'boxgrinder-build', 'lib', 'boxgrinder-core', 'lib' )

require 'rubygems'
require 'torquebox-messaging-container'
require 'consumers/image_consumer'
require 'models/task'
require 'helpers/log-helper'
require 'logger'
require 'base64'

module BoxGrinder
  module Node

    LOG = BoxGrinder::LogHelper.new

    class Initializer
      def initialize
        @log = LOG

        listen
      end

      def listen
        container = TorqueBox::Messaging::Container.new {

          naming_provider_url 'jnp://10.1.0.13:1099/'

          consumers {
            map ImageConsumer, '/queues/boxgrinder/fedora/12/i386/image'
          }
        }

        @log.info "Starting BoxGrinder REST node..."
        container.start
        @log.info "BoxGrinder REST node is started and waiting for tasks."
        container.wait_until( 'INT' )
      end
    end
  end
end

BoxGrinder::Node::Initializer.new

