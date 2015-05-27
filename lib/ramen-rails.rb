require 'ramen-rails/railtie' if defined?(Rails) && defined?(Rails::Railtie)
require 'ramen-rails/config'
require 'ramen-rails/script_tag_helper'
require 'ramen-rails/ramen_after_filter'
require 'ramen-rails/import'

module RamenRails
  def self.config
    block_given? ? yield(Config) : Config
  end
end
