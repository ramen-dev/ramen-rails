module Ramen 
  module Generators
    class ConfigGenerator < ::Rails::Generators::Base

      def self.source_root
        File.dirname(__FILE__)
      end

      argument :organization_id, :desc => "Your Ramen organization ID"
      argument :organization_secret, :desc => "Your Ramen organization Secret"

      def create_config_file
        @organization_id = organization_id
        @organization_secret = organization_secret
        template("ramen.rb.erb", "config/initializers/ramen.rb")
      end

    end
  end
end
