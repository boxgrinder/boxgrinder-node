class BuildImageCommand

  def initialize( task, options = {} )
    @task = task
    @log              = options[:log] || Logger.new(STDOUT)
    @appliance_config = @task.data[:appliance_config].init
    @format           = @task.data[:format]
  end

  def execute
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
        logger.error "Not valid image format:' #{@format}'."
    end

    @log.info command

    return

    #@image.status = Image::STATUSES[:building]
    #save_object( @image )

    RestClient.put "http://10.1.0.13:8080/api/images/#{@image.id}", :status => :building

    begin
      execute_command("cd #{Rails.root} && PATH='/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin' /bin/bash -c 'rake -f boxgrinder.rake #{command}'")
      #@image.status = Image::STATUSES[:built]
      RestClient.put "http://10.1.0.13:8080/api/images/#{@image.id}", :status => :built
      logger.info "Image with id = #{@image.id} was built successfully."
    rescue
      #@image.status = Image::STATUSES[:error]
      RestClient.put "http://10.1.0.13:8080/api/images/#{@image.id}", :status => :error
      logger.error "An error occurred while building image with id = #{@image.id}. Check logs for more info."
    end

    #save_object( @image )
  end
end
