require 'uri'
require 'cgi'
require 'net/http'
module RamenRails
  class Import
    def self.all_users
      User.all.each do |u|
        new(user: u).import
      end

      nil
    end

    attr_accessor :user

    def initialize(opts)
      self.user = opts[:user]
    end

    def can_get_labels?
      RamenRails.config.import_user_labels.present?
    end

    def can_get_value?
      RamenRails.config.import_user_value.present?
    end

    def get_labels
      user.
        instance_eval(&RamenRails.config.import_user_labels)
    end

    def get_value
      user.
        instance_eval(&RamenRails.config.import_user_value)
    end

    def import
      obj = {}
      [:email, :name, :id].each do |attr|
        obj[attr] = user.send(attr)
      end

      obj[:labels] = get_labels if can_get_labels?
      obj[:value] = get_value if can_get_value?

      if user.respond_to?(:created_at) && user.send(:created_at).present?
        obj[:created_at] = user.send(:created_at).to_i
      end
      
      ts = Time.now.to_i

      auth_hash = (Digest::SHA256.new << "#{obj[:email]}:#{obj[:id]}:#{obj[:name]}:#{ts}:#{RamenRails.config.organization_secret}").to_s
      
      h = {
        organization_id: RamenRails.config.organization_id,
        user: obj,
        timestamp: ts,
        auth_hash: auth_hash,
        import: true
      }

      json = h.to_json

      endpoint = ENV['RAMEN_IMPORT_URI'] || "https://ramen.is/po.json"
      uri = URI("#{endpoint}?json_payload=#{CGI.escape(json)}")
      start = Time.now.to_f
      resp = Net::HTTP.get_response(uri)
      total = Time.now.to_f - start

      if resp.code == "200"
        puts "Imported #{obj[:name]} <#{obj[:email]}> in #{total} seconds"
      else
        puts "ERROR (#{resp.code}) Importing #{obj[:name]} <#{obj[:email]}>. Continuing...."
        puts resp.body.to_s
      end
    end
  end
end
