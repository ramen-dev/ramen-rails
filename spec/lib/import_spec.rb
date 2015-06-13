require 'spec_helper'

describe "RamenRails::Import" do

  before :each do
    @user = Hashie::Mash.new(name: 'Ryan', email: 'ryan@ramen.is', id: '1234')
    @organization_id = rand(1_000_000)
    @organization_secret = rand(1_000_000)

    RamenRails.config do |config|
      config.organization_id = @organization_id
      config.organization_secret = @organization_secret
      config.current_user = Proc.new { @user }
    end
  
    @importer = RamenRails::Import.new
    @importer.user = @user
  end

  it "should have user info in hash" do
    expect(@importer.generate_hash[:user][:email]).
      to eq('ryan@ramen.is')
  end

  it "should not have company data" do
    expect(@importer.generate_hash[:company]).to be_nil
  end

  it "should set :import true" do
    expect(@importer.generate_hash[:import]).to eq(true)
  end

  context "with a company" do
    before :each do
      @company = Hashie::Mash.new({id: 1234, url: 'https://ramen.is', name: 'Fake Rake'})
      @importer.company = @company
    end

    it "should have company data" do
      expect(@importer.generate_hash[:company][:id]).
        to eq("1234")
    end
  end
end
