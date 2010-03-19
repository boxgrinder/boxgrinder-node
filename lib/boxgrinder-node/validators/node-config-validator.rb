# JBoss, Home of Professional Open Source
# Copyright 2009, Red Hat Middleware LLC, and individual contributors
# by the @authors tag. See the copyright.txt in the distribution for a
# full listing of individual contributors.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
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

module BoxGrinder
  module Node
    class NodeConfigValidator
      def initialize
        raise "You're trying to run BoxGrinder Node on unsupported platform" unless File.exists?( '/etc/redhat-release' )

        redhat_release = File.read( '/etc/redhat-release' )

        raise "You're trying to run BoxGrinder Node on unsupported platform" unless redhat_release.match( /^Red Hat Enterprise Linux/ ) or redhat_release.match( /^Fedora/ )
      end

      def validate( config_file )
        return unless File.exists?( config_file )

        config = YAML.load_file( config_file )

        raise "Invalid config file" if config.nil?
        raise "Build location path specified in config file (#{config['build_location']}) doesn't exist." unless config['build_location'].nil? or File.exists?( config['build_location'] )        
      end
    end
  end
end