require 'boxgrinder-node/commands/build-image-command'
require 'boxgrinder-node/commands/remove-image-command'
require 'boxgrinder-core/models/appliance-config'

module BoxGrinder
  module Node
    class ImageConsumer
      def on_object( payload )
        @task = payload

        @log = LOG

        @log.info "Received new task."

        case @task.action
          when Image::ACTIONS[:build] then
            BuildImageCommand.new( @task, :log => @log ).execute
          when Image::ACTIONS[:remove] then
            #RemoveImageCommand.new( @task.artifact, :log => @log ).execute
        end
      end
    end
  end
end