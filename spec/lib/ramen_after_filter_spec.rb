require 'spec_helper'

describe 'After filter' do

  before :each do
    @dummy = Hashie::Mash.new({
      response: {
        content_type: 'text/html',
        body: "<html><body>hi</body>"
      }
    })
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

      it "should attach tag" do
        filter = RamenRails::RamenAfterFilter.filter(@dummy)
        expect(@dummy.response.body).to include("script")
        expect(@dummy.response.body).to include("Angilly")
        expect(@dummy.response.body).to_not include("company")
      end

      describe "and a company" do
        before :each do
          RamenRails.config do |c|
            c.current_company = Proc.new { Hashie::Mash.new(name: 'Scrubber', url: 'https://scrubber.social') }
          end
        end

        it "should attach user & company" do
          filter = RamenRails::RamenAfterFilter.filter(@dummy)
          expect(@dummy.response.body).to include("script")
          expect(@dummy.response.body).to include("Angilly")
          expect(@dummy.response.body).to include("company")
          expect(@dummy.response.body).to include("Scrubber")
        end
      end

    end
  end
end
