require 'rubygems'

Gem::Specification.new do |s|
  s.platform  = Gem::Platform::RUBY
  s.name      = "boxgrinder-node"
  s.version   = "0.0.1"
  s.author    = "BoxGrinder Project"
  s.homepage  = "http://www.jboss.org/stormgrind/projects/boxgrinder.html"
  s.email     = "info@boxgrinder.org"
  s.summary   = "BoxGrinder Node files"
  s.files     = Dir['lib/**/*.rb'] << 'README' << 'LICENSE'
  s.executables << 'boxgrinder-node'

  s.add_dependency('boxgrinder-build', '>= 0.0.1')
end
