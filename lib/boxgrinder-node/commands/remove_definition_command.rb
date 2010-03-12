require 'commands/base_command'

class RemoveDefinitionCommand
  include BaseCommand
 
  def initialize( definition )
    @definition = definition
  end

  def execute
    logger.info "Removing definition with id = #{@definition.id}..."

    begin
      execute_command("sudo /bin/bash -c 'rm -f #{@definition.file}'")

      Definition.destroy( @definition.id )

      logger.info "Definition with id = #{@definition.id}, name = #{@definition.name} was removed successfully."
    rescue
      @definition.status = Definition::STATUSES[:error]
      @definition.save!
      logger.error "An error occurred while removing definition with id = #{@definition.id}. Check logs for more info."
    end
  end
end
