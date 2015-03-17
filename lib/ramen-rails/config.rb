module RamenRails
  module Config
    class NoLambdasPlease < StandardError; end

    class << self

      def ensure_not_lambda!(v)
        if v.lambda?
          raise NoLambdasPlease.new <<-ERR
            You passed me a lambda (ie. `-> { a_thing }`) and not a Proc (ie. `Proc.new { a_thing }`).
            This is important because of some inconsistencies in the way different versions of Ruby
            yield arguments to blocks. Please pass me a Proc, not a lambda :)
          ERR
        end
      end

      def reset!
        instance_variables.each do |v|
          instance_variable_set v, nil
        end
      end

      def current_company=(value)
        raise ArgumentError, "current_company should be a Proc" unless value.kind_of?(Proc)
        ensure_not_lambda!(value)

        @current_company = value
      end

      def current_company
        @current_company
      end

      def current_user=(value)
        raise ArgumentError, "current_user should be a Proc" unless value.kind_of?(Proc)
        ensure_not_lambda!(value)
        
        @current_user = value
      end

      def current_user
        @current_user
      end

      def current_user_value=(value)
        raise ArgumentError, "current_user_value should be a Proc" unless value.kind_of?(Proc)
        ensure_not_lambda!(value)
        
        @current_user_value = value
      end

      def current_user_value
        @current_user_value
      end


      def current_user_labels=(value)
        raise ArgumentError, "current_user_labels should be a Proc" unless value.kind_of?(Proc)
        ensure_not_lambda!(value)
        
        @current_user_labels = value
      end

      def current_user_labels
        @current_user_labels
      end

      def organization_id=(value)
        @organization_id = value
      end

      def organization_id
        @organization_id
      end

      def organization_secret=(value)
        @organization_secret = value
      end

      def organization_secret
        @organization_secret
      end
    end

  end
end
