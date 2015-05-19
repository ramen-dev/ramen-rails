require 'spec_helper'

describe 'After filter' do

  before :each do
    @dummy = Hashie::Mash.new({
      request: {
      original_url: "http://hiryan.com",
    },

    response: {
      content_type: 'text/html',
      body: "<html><body>hi</body>"
    }
    })

    module Rails
      class LogProxy
        def debug(msg)
        end
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
        @dummy.current_user = {email: 'ryan@ramen.is', name: 'Ryan Angilly', id: 'person-1234'}
      end

      context "that does not respond to name" do
        before :each do
          @dummy.current_user = {email: 'ryan@ramen.is', id: 'person-1234'}
        end

        it "should render a comment erro" do
          RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include("See logs")
        end
      end

      context "with a value proc set" do
        before :each do |c|
          @dummy.current_user.value = 1000
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

      context "that responds to created_at" do
        before :each do
          @time = Time.new(2014, 11, 10) 
          @dummy.current_user.created_at = @time 
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
        before :each do
          RamenRails.config do |c|
            c.current_company = Proc.new { Hashie::Mash.new(name: 'Scrubber', url: 'https://scrubber.social') }
            c.current_user_labels = Proc.new { ["ryan", "gold"] }
          end
        end

        pending "should attach user & company" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include("script")
          expect(@dummy.response.body).to include("Angilly")
          expect(@dummy.response.body).to include("company")
          expect(@dummy.response.body).to include("Scrubber")
          expect(@dummy.response.body).to include("gold")
        end
      end

    end
  end
end
