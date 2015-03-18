# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ramen-rails/version"

Gem::Specification.new do |s|
  s.name        = "ramen-rails"
  s.version     = RamenRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ryan Angilly"]
  s.email       = ["ryan@ramen.is"]
  s.homepage    = "https://ramen.is"
  s.summary     = %q{Rails gem for Ramen}
  s.description = %q{Ramen helps B2B SaaS product teams build better products through workflow-enhance customer development}


  s.add_development_dependency "actionpack"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "hashie"
  s.add_development_dependency "timecop"

  s.add_dependency "activesupport"

  s.rubyforge_project = "ramen-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
