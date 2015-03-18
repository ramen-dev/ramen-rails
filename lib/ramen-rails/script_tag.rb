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

    def generate
      if ramen_settings.blank?
        raise EmptySettings.new("need to pass ramen_script_tag a non-empty ramen_settings argument")
      end

      add_auth_hash!

      ramen_script = <<-RAMEN_SCRIPT
  <script id="RamenSettingsScriptTag">
    window.ramenSettings = #{ActiveSupport::JSON.encode(ramen_settings)};
  </script>
  <script src="https://cdn.ramen.is/assets/ramen.js" async></script>
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

      if ramen_settings[:timestamp]
        secret_string = "#{user[:email]}:#{user[:id]}:#{user[:name]}:#{ramen_settings[:timestamp]}:#{options[:organization_secret]}"
      else
        secret_string = "#{user[:email]}:#{user[:id]}:#{user[:name]}:#{options[:organization_secret]}"
      end

      ramen_settings[:auth_hash] = (Digest::SHA2.new << secret_string).to_s
    end

    def controller
      template.try :controller
    end

  end
end
