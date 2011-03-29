# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{boxgrinder-node}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["BoxGrinder Project"]
  s.date = %q{2011-03-01}
  s.default_executable = %q{boxgrinder-node}
  s.description = %q{BoxGrinder Node}
  s.email = %q{info@boxgrinder.org}
  s.executables = ["boxgrinder-node"]
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README", "bin/boxgrinder-node", "lib/boxgrinder-node/consumers/base-image-consumer.rb", "lib/boxgrinder-node/consumers/build-image-consumer.rb", "lib/boxgrinder-node/consumers/convert-image-consumer.rb", "lib/boxgrinder-node/consumers/create-image-consumer.rb", "lib/boxgrinder-node/consumers/deliver-image-consumer.rb", "lib/boxgrinder-node/consumers/destroy-image-consumer.rb", "lib/boxgrinder-node/consumers/management-consumer.rb", "lib/boxgrinder-node/models/node-config.rb", "lib/boxgrinder-node/node.rb", "lib/boxgrinder-node/validators/node-validator.rb", "lib/boxgrinder-node/validators/schemas/config_file_schema.yml"]
  s.files = ["CHANGELOG", "LICENSE", "README", "Rakefile", "bin/boxgrinder-node", "boxgrinder-node.gemspec", "lib/boxgrinder-node/consumers/base-image-consumer.rb", "lib/boxgrinder-node/consumers/build-image-consumer.rb", "lib/boxgrinder-node/consumers/convert-image-consumer.rb", "lib/boxgrinder-node/consumers/create-image-consumer.rb", "lib/boxgrinder-node/consumers/deliver-image-consumer.rb", "lib/boxgrinder-node/consumers/destroy-image-consumer.rb", "lib/boxgrinder-node/consumers/management-consumer.rb", "lib/boxgrinder-node/models/node-config.rb", "lib/boxgrinder-node/node.rb", "lib/boxgrinder-node/validators/node-validator.rb", "lib/boxgrinder-node/validators/schemas/config_file_schema.yml", "spec/node-spec.rb", "Manifest"]
  s.homepage = %q{http://boxgrinder.org/rest/}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Boxgrinder-node", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{BoxGrinder}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{BoxGrinder Node}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<boxgrinder-core>, [">= 0.2.1"])
      s.add_runtime_dependency(%q<kwalify>, [">= 0"])
      s.add_runtime_dependency(%q<open4>, [">= 0"])
      s.add_runtime_dependency(%q<hashery>, [">= 0"])
      s.add_runtime_dependency(%q<org.torquebox.messaging-container>, [">= 1.0.0.CR1"])
      s.add_runtime_dependency(%q<org.torquebox.messaging-client>, [">= 1.0.0.CR1"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<boxgrinder-core>, [">= 0.2.1"])
      s.add_dependency(%q<kwalify>, [">= 0"])
      s.add_dependency(%q<open4>, [">= 0"])
      s.add_dependency(%q<hashery>, [">= 0"])
      s.add_dependency(%q<org.torquebox.messaging-container>, [">= 1.0.0.CR1"])
      s.add_dependency(%q<org.torquebox.messaging-client>, [">= 1.0.0.CR1"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<boxgrinder-core>, [">= 0.2.1"])
    s.add_dependency(%q<kwalify>, [">= 0"])
    s.add_dependency(%q<open4>, [">= 0"])
    s.add_dependency(%q<hashery>, [">= 0"])
    s.add_dependency(%q<org.torquebox.messaging-container>, [">= 1.0.0.CR1"])
    s.add_dependency(%q<org.torquebox.messaging-client>, [">= 1.0.0.CR1"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
