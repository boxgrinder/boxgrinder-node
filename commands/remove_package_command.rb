require 'commands/base_command'

class RemovePackageCommand
  include BaseCommand

  def initialize( package )
    @package = package
  end

  def execute
    logger.info "Removing package with id = #{@package.id} and #{@package.package_format} format..."

    command = "cd #{Rails.root} && sudo /bin/bash -c 'rm -rf #{@package.file}'"

    logger.debug "Executing command: #{command}"

    `#{command}`

    if $?.to_i != 0
      @package.status = Package::STATUSES[:error]
      logger.error "An error occurred while building package with id = #{@package.id}. Check logs for more info."
      @package.save!
    else
      logger.info "Package with id = #{@package.id} was successfully removed."
      Package.destroy( @package.id )
    end
  end
end
