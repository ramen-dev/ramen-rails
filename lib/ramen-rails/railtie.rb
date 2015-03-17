require 'ramen-rails/script_tag_helper'
require 'ramen-rails/ramen_after_filter'

module RamenRails
  class Railtie < Rails::Railtie
    initializer "ramen_rails.script_tag_helper.rb" do |app|
      ActionView::Base.send :include,
        ScriptTagHelper
    end

    initializer "ramen_rails.auto_include_filter.rb" do |app|
      ActionController::Base.send :after_filter, 
        AutoIncludeFilter 
    end
  end
end
