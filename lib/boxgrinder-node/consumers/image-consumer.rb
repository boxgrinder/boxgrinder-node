require 'boxgrinder-node/commands/build-image-command'
require 'boxgrinder-node/commands/remove-image-command'
require 'boxgrinder-core/models/appliance-config'
require 'boxgrinder-core/models/task'

module BoxGrinder
  module Node
    class ImageConsumer
      def on_object( payload )
        @task         = payload
        @log          = LOG
        @node_config  = NODE_CONFIG

        @log.info "Received new task."

        begin
          case @task.action
            when :build then
              BuildImageCommand.new( @task, @node_config, :log => @log ).execute
            when :remove then
              #RemoveImageCommand.new( @task.artifact, :log => @log ).execute
          end
        rescue => e
          @log.error e
          @log.error "An error occurred while executing task. See above for more info."
          # TODO resend information about error or put this task back into queue
        end

        @log.info "Task handled."

      end
    end
  end
end