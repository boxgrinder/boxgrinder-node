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

require 'rubygems'
require 'spec/rake/spectask'
require 'echoe'

Echoe.new("boxgrinder-node") do |p|
  p.project = "BoxGrinder"
  p.author = "BoxGrinder Project"
  p.summary = "BoxGrinder Node"
  p.url = "http://boxgrinder.org/rest/"
  p.email = "info@boxgrinder.org"
  p.runtime_dependencies = [
      'boxgrinder-core >=0.2.1',
      'kwalify',
      'open4',
      'hashery',
      'org.torquebox.messaging-container >=1.0.0.CR1',
      'org.torquebox.messaging-client >=1.0.0.CR1'
  ]
  p.development_dependencies = [
      'echoe',
      'rcov'
  ]
end

desc "Run all tests"
Spec::Rake::SpecTask.new('spec') do |t|
  t.rcov = false
  t.spec_files = FileList["spec/**/*-spec.rb"]
  t.spec_opts = ['--colour', '--format', 'specdoc', '-b']
  t.verbose = true
end

desc "Run all tests and generate code coverage report"
Spec::Rake::SpecTask.new('spec:coverage') do |t|
  t.spec_files = FileList["spec/**/*-spec.rb"]
  t.spec_opts = ['--colour', '--format', 'html:pkg/rspec_report.html', '-b']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,/lib/,\(eval\)']
  t.verbose = true
end
