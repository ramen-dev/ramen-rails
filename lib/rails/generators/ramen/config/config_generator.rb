module Ramen 
  module Generators
    class ConfigGenerator < ::Rails::Generators::Base

      def self.source_root
        File.dirname(__FILE__)
      end

      argument :org_id, :desc => "Your Rails organization ID"
      argument :org_secret, :desc => "Your Rails organization Secret"

      def create_config_file
        @org_id = org_id
        @org_secret = org_secret
        template("ramen.rb.erb", "config/initializers/ramen.rb")
      end

    end
  end
end
