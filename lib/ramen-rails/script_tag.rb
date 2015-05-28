require "active_support/json"
require "active_support/core_ext/hash/indifferent_access"

module RamenRails
  class ScriptTag
    class EmptySettings < StandardError; end

    def self.generate(template, ramen_settings, options = {})
      st = new(template, ramen_settings, options)
      st.generate
    end

    attr_accessor :template, :ramen_settings, :options
    def initialize(template, ramen_settings, options = {})
      self.template = template
      self.ramen_settings = ramen_settings
      self.options = options
    end

    def ramen_js_asset_uri
      RamenRails.config.ramen_js_asset_uri || "https://cdn.ramen.is/assets/ramen.js"
    end

    def generate
      if ramen_settings.blank?
        raise EmptySettings.new("need to pass ramen_script_tag a non-empty ramen_settings argument")
      end

      ramen_settings[:timestamp] ||= Time.now.to_i
      
      add_auth_hash!

      ramen_script = <<-RAMEN_SCRIPT
  <script id="RamenSettingsScriptTag">
    (function() {
      var opts = #{ActiveSupport::JSON.encode(ramen_settings)};
      window.ramenSettings = window.ramenSettings || {};
      for (var property in opts) {
        if (opts.hasOwnProperty(property)) {
          window.ramenSettings[property] = opts[property];
        }
      }
    })()
  </script>
  <script src="#{ramen_js_asset_uri}" async></script>
      RAMEN_SCRIPT

      if controller
        controller.
          instance_variable_set(RamenRails::SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE, true)
      end

      ramen_script.respond_to?(:html_safe) ? ramen_script.html_safe : ramen_script
    end

    def add_auth_hash!
      return unless ramen_settings[:user].present? &&
        options[:organization_secret].present? &&
        ramen_settings[:auth_hash].blank?

      user = ramen_settings[:user]

      secret_string = "#{user[:email]}:#{user[:id]}:#{user[:name]}:#{ramen_settings[:timestamp]}:#{options[:organization_secret]}"

      ramen_settings[:auth_hash] = (Digest::SHA2.new << secret_string).to_s
    end

    def controller
      template.try :controller
    end

  end
end
