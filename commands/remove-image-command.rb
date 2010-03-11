require 'helpers/exec-helper'

module BoxGrinderREST
  class RemoveImageCommand
    def initialize( image, options = {} )
      @image        = image
      @log          = options[:log]         || Logger.new(STDOUT)
      @exec_helper  = options[:exec_helper] || ExecHelper.new( :log => @log )
    end

    def execute
      @log.info "Removing image '#{@image[:name]}' and '#{@image[:format]}' format..."

      begin
        @exec_helper.execute "sudo rm -rf #{@image[:directory]}"
        @log.info "Image '#{@image[:name]}' was successfully removed."
        #TODO: image destroy
      rescue
        @log.error "An error occurred while removing image '#{@image[:name]}'. Check logs for more info."
        # TODO: status ERROR
      end
    end
  end
end