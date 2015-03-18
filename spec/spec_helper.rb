require 'rspec'
require 'ramen-rails'
require 'hashie/mash'
require 'timecop'

RSpec.configure do |config|

  config.before :each do
    RamenRails.config.reset!
  end

end
