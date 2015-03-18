module RamenRails

  module AutoInclude
    def add_ramen_script_tag 
      RamenAfterFilter.filter(self)
    end
  end

  class RamenAfterFilter
   
    include ScriptTagHelper
    CLOSING_BODY_TAG = %r{</body>}

    def self.filter(controller)
      auto_include_filter = new(controller)
      return unless auto_include_filter.include_javascript?

      auto_include_filter.include_javascript!
    end

    attr_reader :controller

    def initialize(kontroller)
      @controller = kontroller 
    end

    def include_javascript! 
      response.body = response.body.gsub(CLOSING_BODY_TAG, ramen_script_tag + '\\0')
    end

    def include_javascript?
      !ramen_script_tag_called_manually? &&
        html_content_type? &&
        response_has_closing_body_tag? &&
        ramen_org_id.present? &&
        ramen_user_object.present?
    end

    private
    def response
      controller.response
    end

    def html_content_type?
      response.content_type == 'text/html'
    end

    def response_has_closing_body_tag?
      !!(response.body[CLOSING_BODY_TAG])
    end

    def ramen_script_tag_called_manually?
      controller.instance_variable_get(SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE)
    end

    POTENTIAL_RAMEN_USER_OBJECTS = [
      Proc.new { instance_eval(&RamenRails.config.current_user) if RamenRails.config.current_user.present? },
      Proc.new { current_user },
      Proc.new { @user }
    ]

    def ramen_user_labels
      return nil unless ramen_user_object
      instance_eval(&RamenRails.config.current_user_labels) if RamenRails.config.current_user_labels.present?
    rescue NameError => e
      Rails.logger.debug "Swallowing NameError. We're probably in an Engine or some other context like Devise."
      Rails.logger.debug e
    
      nil
    end

    def ramen_user_object
      POTENTIAL_RAMEN_USER_OBJECTS.each do |potential_user|
        begin
          user = controller.instance_eval &potential_user
          return user if user.present? && 
            (user.email.present? || user.id.present?)
        rescue NameError
          next
        end
      end

      nil
    end

    def ramen_user_value
      return nil unless ramen_user_object
      instance_eval(&RamenRails.config.current_user_value) if RamenRails.config.current_user_value.present?
    rescue NameError => e
      Rails.logger.debug "Swallowing NameError. We're probably in an Engine or some other context like Devise."
      Rails.logger.debug e
    
      nil
    end

    def ramen_org_id
      return ENV['RAMEN_ORGANIZATION_ID'] if ENV['RAMEN_ORGANIZATION_ID'].present?
      return RamenRails.config.organization_id if RamenRails.config.organization_id.present?
      return 'organization-id' if defined?(Rails) && Rails.env.development?
    
      nil
    end

    def ramen_org_secret
      return ENV['RAMEN_ORGANIZATION_SECRET'] if ENV['RAMEN_ORGANIZATION_SECRET'].present?
      return RamenRails.config.organization_secret if RamenRails.config.organization_secret.present?
      return 'organization-secret' if defined?(Rails) && Rails.env.development?
    
      nil
    end

    def ramen_company
      return nil unless ramen_user_object
      
      begin
        company = instance_eval(&RamenRails.config.current_company) if RamenRails.config.current_company.present?
      rescue NameError => e
        Rails.logger.debug "Swallowing NameError. We're probably in an Engine or some other context like Devise."
        Rails.logger.debug e

        company = nil
      end
      
      return nil unless company

      obj = {}
      [:url, :id, :value, :name].each do |attr|
        obj[attr] = company.send(attr) if company.respond_to?(attr) &&
          company.send(attr).present?
      end
    
      obj
    end


    def ramen_script_tag
      obj = {}
      obj[:organization_id] = ramen_org_id
      obj[:user] = {}
      obj[:timestamp] = Time.now.to_i

      user = ramen_user_object

      obj[:user][:id] = user.id if user.respond_to?(:id) && user.id.present?

      [:email, :name].each do |attr|
        obj[:user][attr] = user.send(attr) if user.respond_to?(attr) && user.send(attr).present?
      end
      
      obj[:user][:value] = ramen_user_value if ramen_user_value.present?
      obj[:user][:labels] = ramen_user_labels unless ramen_user_labels.nil?
      
      obj[:company] = ramen_company if ramen_company.present?

      super(obj, organization_secret: ramen_org_secret)
    end

  end
end
