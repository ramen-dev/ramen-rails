source "https://rubygems.org"
gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
when "rails3"
  "~> 3.1.0"
else
  "~> 4.0"
end

gem "rails", rails
