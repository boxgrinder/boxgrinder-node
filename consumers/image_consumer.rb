require 'commands/build-image-command'
require 'commands/remove-image-command'
require 'models/image'
require 'boxgrinder-core/models/appliance-config'

module BoxGrinder
  module Node
    class ImageConsumer
      def on_object( payload )
        @task = payload

        @log = LOG

        @log.info "Received new task."

        puts @task.to_yaml

        sleep 10
        puts "done"

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