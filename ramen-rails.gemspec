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


  s.add_development_dependency "actionpack", "~>4.0"
  s.add_development_dependency "rake", "~>10.4"
  s.add_development_dependency "rspec", "~>3.2"
  s.add_development_dependency "hashie", "~>3.4"
  s.add_development_dependency "timecop", "~>0.7"

  s.add_dependency "activesupport", "~>4.0"

  s.rubyforge_project = "ramen-rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
