require 'boxgrinder-node/helpers/queue-helper'
require 'boxgrinder-core/helpers/exec-helper'

module BoxGrinder
  module Node
    class BuildImageCommand

      def initialize( task, options = {} )
        @task             = task
        @log              = options[:log]           || Logger.new(STDOUT)
        @queue_helper     = options[:queue_helper]  || QueueHelper.new( :log => @log )
        @exec_helper      = options[:exec_helper]   || ExecHelper.new( :log => @log )

        @appliance_config = @task.data[:appliance_config].init
        @format           = @task.data[:format]
        @image_id         = @task.data[:image_id]
      end

      def execute
        store_definition

        @log.info "Building image for '#{@appliance_config.name}' (#{@appliance_config.hardware.arch}) appliance and '#{@format}' format..."

        command = nil

        case @format
          when 'VMWARE' then
            command = "appliance:#{@appliance_config.name}:vmware:personal appliance:#{@appliance_config.name}:vmware:enterprise"
          when 'EC2' then
            command = "appliance:#{@appliance_config.name}:ec2"
          when 'RAW' then
            command = "appliance:#{@appliance_config.name}"
          else
            @log.error "Not valid image format:' #{@format}'."
        end

        @queue_helper.enqueue( IMAGE_MANAGEMENT_QUEUE, { :id => @image_id, :status => :building }, "10.1.0.13" )

        begin
          @exec_helper.execute "rake #{command}"

          @log.info "Image for '#{@appliance_config.name}' (#{@appliance_config.hardware.arch}) appliance and '#{@format}' format was built successfully."
          @queue_helper.enqueue( IMAGE_MANAGEMENT_QUEUE,
                                 {
                                         :id      => @image_id,
                                         :status  => :built
                                 },
                                 "10.1.0.13"
          )
        rescue
          @log.error "An error occurred while building image for '#{@appliance_config.name}' (#{@appliance_config.hardware.arch}) appliance and '#{@format}' format. Check logs for more info."
          @queue_helper.enqueue( IMAGE_MANAGEMENT_QUEUE,
                                 {
                                         :id      => @image_id,
                                         :status  => :error
                                 },
                                 "10.1.0.13"
          )
        end
      end

      def store_definition
        @log.debug "Storing definition file for '#{@appliance_config.name}' appliance..."

        appliances_dir  = "#{BASE_DIR}/appliances"
        file            = "#{appliances_dir}/#{@appliance_config.name}.appl"

        FileUtils.mkdir_p( appliances_dir )
        File.open(file, 'w') {|f| f.write(@appliance_config.definition.to_yaml) }

        @log.debug "Definition stored in '#{file}' file."
      end
    end
  end
end