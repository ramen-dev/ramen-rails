require 'spec_helper'

module Dummy
  Controller = Struct.new(:request, :response, :current_user, :ramen_script_tag_options)
  Request = Struct.new(:original_url)
  Response = Struct.new(:content_type, :body)

  class User
    def self.with(attrs)
      user_class = Struct.new(*attrs.keys) do 
        def set(attrs)
          @extras ||= Hashie::Mash.new
          attrs.each {|k,v| @extras[k.to_s] = v }
        end

        def method_missing(name, *args, &block)
          @extras ||= Hashie::Mash.new
          if @extras.key?(name.to_s)
            @extras[name.to_s]
          else
            super
          end
        end

        def respond_to?(name)
          @extras ||= Hashie::Mash.new
          @extras.key?(name.to_s) or super
        end

      end

      user = user_class.new

      attrs.each {|k, v| user.send("#{k}=", v) }

      user
    end
  end
end

describe 'After filter' do

  before :each do
    req = Dummy::Request.new("http://hiryan.com")
    resp = Dummy::Response.new("text/html", "<html><body>hi</body></html>")
    @dummy = Dummy::Controller.new(req, resp)

    module Rails
      class LogProxy
        def debug(msg)
        end

        alias fatal debug
      end

      def self.env
        Hashie::Mash.new({
          :development? => nil,
          :production? => nil
        })
      end

      def self.logger
        LogProxy.new
      end
    end
  end

  describe "with no config" do
    it "should not attach tag" do
      filter = RamenRails::RamenAfterFilter.filter(@dummy)
      expect(@dummy.response.body).to_not include("script")
    end
  end

  describe "with a config" do
    before :each do
      RamenRails.config do |c|
        c.organization_id = 1234
        c.organization_secret = 5678
      end
    end

    it "should not attach tag" do
      filter = RamenRails::RamenAfterFilter.filter(@dummy)
      expect(@dummy.response.body).to_not include("script")
    end

    describe "and a user" do
      before :each do
        @dummy.current_user = Dummy::User.with(email: 'ryan@ramen.is', name: 'Ryan Angilly', id: 'person-1234')
      end

      context "that does not respond to name" do
        before :each do
          @dummy.current_user = Dummy::User.with(email: 'ryan@ramen.is', id: 'person-1234')
        end

        it "should render a comment error" do
          RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include("See your Rails logs")
        end
      end

      context "with an object id" do
        before :each do
          @dummy.current_user = Dummy::User.with(email: 'ryan@ramen.is', name: 'Ryan Angilly', id: {'$oid' => 'person-1234'})
        end

        it "should to_s the ID" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include(%q|id":"{\"$oid\"|)
        end
      end

      context "with enabled_environments set to empty" do
        before :each do |c|
          RamenRails.config do |c|
            c.enabled_environments = []
          end
        end

        it "not render script tag" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to_not include("ramenSettings")
          expect(@dummy.response.body).to include("Ramen not enabled for environment")
        end
      end

      context "with a value proc set" do
        before :each do |c|
          @dummy.current_user.set value: 1000
          RamenRails.config do |c|
            c.current_user_value = Proc.new { current_user.value }
          end
        end

        context "and ramen_script_tag_options" do
          before :each do |c|
            @dummy.ramen_script_tag_options = {survey_id: 'survey_ryan'}
          end

          it "should include value in output" do
            filter = RamenRails::RamenAfterFilter.filter(@dummy)

            expect(@dummy.response.body).to include("survey_ryan")
            expect(@dummy.response.body).to include("survey_id")
          end 
        end


        it "should include value in output" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)

          expect(@dummy.response.body).to include("value")
        end 

      end

      context "that responds to traits" do
        before :each do
          @dummy.current_user.set(traits: {bucket: 6, is_friend: true, original_name: "Netflix"})
        end

        it "should attach traits to company" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include('"is_friend":true')
        end
      end

      context "that responds to #persisted? with false" do
        before :each do
          @dummy.current_user.set persisted?: false
        end

        it "should not render anything" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to_not include("ramenSettings")
        end
      end

      context "that responds to #persisted? with true" do
        before :each do
          @dummy.current_user.set persisted?: true
        end

        it "should render the tag" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include("ramenSettings")
        end
      end

      context "that responds to created_at" do
        before :each do
          @time = Time.new(2014, 11, 10) 
          @dummy.current_user.set created_at: @time 
        end

        it "should include created_at in output" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include("created_at")
          expect(@dummy.response.body).to include(@time.to_i.to_s)
        end 
      end

      it "should attach tag" do
        Timecop.freeze do
          ts = Time.now.to_i
          auth_hash = (Digest::SHA2.new << "ryan@ramen.is:person-1234:Ryan Angilly:5678").to_s
          ts_auth_hash = (Digest::SHA2.new << "ryan@ramen.is:person-1234:Ryan Angilly:#{ts}:5678").to_s

          filter = RamenRails::RamenAfterFilter.filter(@dummy)

          expect(@dummy.response.body).to_not include(auth_hash)
          expect(@dummy.response.body).to include(ts_auth_hash)
          expect(@dummy.response.body).to_not include("value")
          expect(@dummy.response.body).to include("script")
          expect(@dummy.response.body).to include("Angilly")
          expect(@dummy.response.body).to_not include("created_at")
          expect(@dummy.response.body).to include("hiryan.com")
          expect(@dummy.response.body).to_not include("company")
          expect(@dummy.response.body).to_not include("custom_links")
        end
      end

      context "and custom links" do
        before :each do
          RamenRails.config do |c|
            c.custom_links = [
              {
              title: "Submit a bug",
              callback: "$('#submit_bug').modal('show')"
            },

              {
              title: "Knowledge Base",
              href: "/knowedge_base"
            }
            ]
          end
        end

        it "should attach tag" do
          Timecop.freeze do
            ts = Time.now.to_i
            auth_hash = (Digest::SHA2.new << "ryan@ramen.is:person-1234:Ryan Angilly:5678").to_s
            ts_auth_hash = (Digest::SHA2.new << "ryan@ramen.is:person-1234:Ryan Angilly:#{ts}:5678").to_s

            filter = RamenRails::RamenAfterFilter.filter(@dummy)

            expect(@dummy.response.body).to_not include(auth_hash)
            expect(@dummy.response.body).to include(ts_auth_hash)
            expect(@dummy.response.body).to include("script")
            expect(@dummy.response.body).to include("Angilly")
            expect(@dummy.response.body).to include("hiryan.com")
            expect(@dummy.response.body).to_not include("created_at")
            expect(@dummy.response.body).to_not include("company")
            expect(@dummy.response.body).to include("custom_links")
          end

        end
      end

      context "and a company" do        
        context "that has no id" do
          before :each do
            RamenRails.config do |c|
              c.current_company = Proc.new { Hashie::Mash.new(name: 'Scrubber', url: 'https://scrubber.social') }
              c.current_company_labels = Proc.new { ["ryan", "gold"] }
            end
          end

          it "should not attach user & company" do
            filter = RamenRails::RamenAfterFilter.filter(@dummy)
            expect(@dummy.response.body).to include("script")
            expect(@dummy.response.body).to include("Angilly")
            expect(@dummy.response.body).not_to include("company")
            expect(@dummy.response.body).not_to include("Scrubber")
            expect(@dummy.response.body).not_to include("gold")
          end
        end
        
        context "that has an id" do
          before :each do
            RamenRails.config do |c|
              c.current_company = Proc.new { Hashie::Mash.new(id: "1245", name: 'Scrubber', url: 'https://scrubber.social') }
              c.current_company_labels = Proc.new { ["ryan", "goldzz"] }
            end
          end

          context "and traits" do
            before :each do
              RamenRails.config do |c|
                c.current_company = Proc.new {
                  Hashie::Mash.new(id: "1245", name: 'Scrubber', url: 'https://scrubber.social', traits: {plan: 'startup'})
                }
              end
            end

            it "should attach traits to company" do
              filter = RamenRails::RamenAfterFilter.filter(@dummy)
              expect(@dummy.response.body).to include('"plan":"startup"')
            end
          end

          it "should attach user & company" do
            filter = RamenRails::RamenAfterFilter.filter(@dummy)
            expect(@dummy.response.body).to include("script")
            expect(@dummy.response.body).to include("Angilly")
            expect(@dummy.response.body).to include("company")
            expect(@dummy.response.body).to include("Scrubber")
            expect(@dummy.response.body).to include("1245")
            expect(@dummy.response.body).to include("goldzz")
          end
        end
      end
    end
  end
end
