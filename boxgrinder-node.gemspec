require 'rubygems'

Gem::Specification.new do |s|
  s.platform  = Gem::Platform::RUBY
  s.name      = "boxgrinder-node"
  s.version   = "0.0.2"
  s.author    = "BoxGrinder Project"
  s.homepage  = "http://www.jboss.org/stormgrind/projects/boxgrinder.html"
  s.email     = "info@boxgrinder.org"
  s.summary   = "BoxGrinder Node files"
  s.files     = Dir['lib/**/*.rb'] << 'README' << 'LICENSE'
  s.executables << 'boxgrinder-node'

  s.add_dependency('boxgrinder-core', '>= 0.0.8')
  s.add_dependency('torquebox-messaging-container', '>= 1.0.0')
  s.add_dependency('torquebox-messaging-client', '>= 1.0.0')
end
