# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "donedone/version"

Gem::Specification.new do |s|
  s.name        = "donedone"
  s.version     = DoneDone::VERSION
  s.authors     = ["Jonathan Thomas"]
  s.email       = ["buyer+donedone@his-service.net"]
  s.homepage    = "https://github.com/zoodles/DoneDone-API-Ruby"
  s.summary     = %q{donedone.com api client}
  s.description = %q{Check your existing todo items, add new ones, update old one}
  s.rubyforge_project = "donedone"
  s.license     = 'MIT'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.bindir        = 'bin'
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_dependency "mime-types"
  s.add_development_dependency "rspec", "~> 2.14.0"
  #s.add_development_dependency "simplecov"
end
