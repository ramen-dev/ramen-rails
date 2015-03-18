require "ramen-rails/script_tag"

module RamenRails
  SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE = :@_ramen_script_tag_helper_called

  module ScriptTagHelper
    def ramen_script_tag(ramen_settings, options = {})
      ScriptTag.generate(self, ramen_settings, options)
    end
  end
end
