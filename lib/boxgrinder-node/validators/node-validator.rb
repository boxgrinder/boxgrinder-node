#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.

require 'kwalify'

module BoxGrinder
  module Node
    class NodeValidator
      def initialize(config, options = {})
        @config = config
        @log = options[:log] || LogHelper.new(:level => :trace, :type => :stdout)
      end

      def validate
        validate_config_file
      end

      def validate_config_file
        return unless File.exists?(@config.config_file)

        @log.debug "Validating '#{@config.config_file}' configuration file..."

        schema = Kwalify::Yaml.load_file("#{File.dirname(__FILE__)}/schemas/config_file_schema.yml")
        validator = Kwalify::Validator.new(schema)
        document = Kwalify::Yaml.load_file(@config.config_file)
        errors = validator.validate(document)

        if errors && !errors.empty?
          @log.fatal "Configuration file '#{@config.config_file}' is not valid. Found #{errors.size} errors:"
          errors.each do |e|
            @log.error "- #{e.linenum.nil? ? '' : "Line #{e.linenum}, "}#{e.message.capitalize}"
          end
          abort
        else
          @log.debug "Configuration file valid."
        end
      end
    end
  end
end