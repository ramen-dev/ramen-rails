require 'spec_helper'

describe "RamenRails::Config" do

  before :each do
    @user = Hashie::Mash.new(name: 'Ryan', email: 'ryan@ramen.is', id: '1234')
    @company = Hashie::Mash.new(name: 'Scrubber', url: 'http://scrubber.social', id: 'comp-1234')
    @organization_id = rand(1_000_000)
    @organization_secret = rand(1_000_000)
  end

  it "should set things" do
    RamenRails.config do |config|
      config.organization_id = @organization_id
      config.organization_secret = @organization_secret
      config.current_user = Proc.new { @user }
      config.current_company = Proc.new { @company }
    end

    expect(instance_eval(&RamenRails.config.current_user).id).to eq('1234')
    expect(instance_eval(&RamenRails.config.current_company).id).to eq('comp-1234')
    
    expect(RamenRails.config.current_user.call.id).to eq('1234')
    expect(RamenRails.config.current_company.call.id).to eq('comp-1234')
    expect(RamenRails.config.organization_id).to eq(@organization_id)
    expect(RamenRails.config.organization_secret).to eq(@organization_secret)
  end

  it "should error if passed a lambda" do
    expect do
      RamenRails.config do |c|
        c.current_user = -> { @user }
      end
    end.to raise_error(RamenRails::Config::NoLambdasPlease)
  end

end
