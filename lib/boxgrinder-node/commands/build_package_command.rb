require 'commands/base_command'

class BuildPackageCommand
  include BaseCommand

  def initialize( package )
    @package = package
    @image = Image.find( @package.image_id )
    @definition = Definition.find( @image.definition_id )
  end

  def execute
    logger.info "Building #{@package.package_format.upcase} package for #{@image.image_format} image with id = #{@package.image_id}..."

    case @package.package_format
      when Package::FORMATS[:tgz] then
        command = "appliance:#{@definition.name}:package:#{@image.image_format.downcase}:tgz"
      when Package::FORMATS[:zip] then
        command = "appliance:#{@definition.name}:package:#{@image.image_format.downcase}:zip"
      else
        logger.fatal "Not valid format: #{@package.package_format}. It should never happen!"
        return
    end

    @package.status = Package::STATUSES[:building]
    save_object( @package )

    begin
      execute_command("cd #{Rails.root} && PATH='/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin' /bin/bash -c 'rake -f boxgrinder.rake #{command}'")
      @package.status = Package::STATUSES[:built]
      logger.info "Package with id = #{@package.id} was built successfully."
    rescue
      @package.status = Package::STATUSES[:error]
      logger.error "An error occurred while building image with id = #{@package.id}. Check logs for more info."
    end

    save_object( @package )
  end
end
