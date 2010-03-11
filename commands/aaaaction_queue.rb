require 'torquebox/queues/base'
require 'base64'
require 'yaml'
require 'commands/build_image_command'
require 'commands/remove_image_command'
require 'commands/remove_definition_command'
require 'commands/build_package_command'
require 'commands/remove_package_command'

module BoxGrinder
  class ActionQueue
    include TorqueBox::Queues::Base

    def logger
      Rails.logger
    end

    def execute(payload)
      begin
        @params = YAML.load(Base64.decode64(payload))
        @task = @params[:task]
      rescue => e
        logger.error( "An error occurred while decoding received task: #{payload}" )
        logger.error( "#{e}" )
        return
      end

      logger.info( "Executing task for artifact = #{@task.artifact}, artifact_id = #{@task.artifact_id} and action = #{@task.action}" )

      case @task.artifact
        when Defaults::ARTIFACTS[:image] then
          execute_on_image
        when Defaults::ARTIFACTS[:definition] then
          execute_on_definition
        when Defaults::ARTIFACTS[:package] then
          execute_on_package
      end

      logger.info "Task executed."
    end

    private

    def execute_on_image
      #begin
      #  image = load_articaft( Image )
      #rescue => e
      #  logger.error e
      #  return
      #end

      case @task.action
        when Image::ACTIONS[:build] then
          BuildImageCommand.new( @params[:image] ).execute
        when Image::ACTIONS[:remove] then
          RemoveImageCommand.new( @params[:image] ).execute
      end
    end

    def execute_on_definition
      begin
        definition = load_articaft( Definition )
      rescue => e
        logger.error e
        return
      end

      case @task.action
        when Definition::ACTIONS[:remove] then
          RemoveDefinitionCommand.new( definition ).execute
      end

    end

    def execute_on_package
      begin
        package = load_articaft( Package )
      rescue => e
        logger.error e
        return
      end

      case @task.action
        when Package::ACTIONS[:build] then
          BuildPackageCommand.new( package ).execute
        when Package::ACTIONS[:remove] then
          RemovePackageCommand.new( package ).execute
      end

    end

    def load_articaft( name )
      logger.debug "Loading #{name} with id = #{@task.artifact_id}..."

      begin
        artifact = name.find( @task.artifact_id )
      rescue ActiveRecord::RecordNotFound => e
        logger.fatal "#{name} with id = #{@task.artifact_id} not found while executing task."
        logger.fatal( "#{e}" )
        raise e
      end

      logger.debug "#{name} loaded."
      logger.debug "#{artifact.inspect}"

      artifact
    end
  end
end
