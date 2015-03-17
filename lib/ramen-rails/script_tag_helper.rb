require "active_support/json"
require "active_support/core_ext/hash/indifferent_access"

module RamenRails
  SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE = :@_ramen_script_tag_helper_called

  module ScriptTagHelper

    class EmptySettings < StandardError; end

    def ramen_script_tag(ramen_settings, options = {})
      if ramen_settings.blank?
        raise EmptySettings.new("need to pass ramen_script_tag a non-empty ramen_settings argument")
      end

      if ramen_settings[:user].present? && options[:organization_secret].present? && ramen_settings[:auth_hash].blank?
        user_details = ramen_settings[:user]
        secret_string = "#{user_details[:email]}:#{user_details[:id]}:#{user_details[:name]}:#{options[:organization_secret]}"
        ramen_settings[:auth_hash] = (Digest::SHA2.new << secret_string).to_s
      end

      ramen_script = <<-RAMEN_SCRIPT
<script id="RamenSettingsScriptTag">
  window.ramenSettings = #{ActiveSupport::JSON.encode(ramen_settings)};
</script>
<script src="https://cdn.ramen.is/assets/ramen.js" async></script>
      RAMEN_SCRIPT

      controller.instance_variable_set(RamenRails::SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE, true) if defined?(controller)
      ramen_script.respond_to?(:html_safe) ? ramen_script.html_safe : ramen_script
    end
  end
end
