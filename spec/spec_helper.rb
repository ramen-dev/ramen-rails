require 'rspec'
require 'ramen-rails'
require 'hashie/mash'
require 'timecop'
require 'byebug'

RSpec.configure do |config|

  config.before :each do
    RamenRails.config.reset!
  end

end
