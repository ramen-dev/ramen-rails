require 'spec_helper'

class DummyTemplate
  def controller
    @controller ||= Hashie::Mash.new
  end

  include RamenRails::ScriptTagHelper
end


describe 'Script Tag Helper' do

  before :each do
    @template = DummyTemplate.new
  end

  it "should have the false variable" do
    expect(@template.controller.instance_variable_get(RamenRails::SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE)).to be(nil)
  end

  it "should raise if the script tag helper is passed a blank object" do
    expect do
      @template.ramen_script_tag({})
    end.to raise_error(RamenRails::ScriptTag::EmptySettings)
  end

  it "should render the tag" do
    expect(@template.ramen_script_tag({organization_id: 1234})).to include("1234")
  end

  it "should not add auth_hash unless secret is given" do
    ramen_settings = {
      organization_id: rand(1_000_000),
      user: {
        email: 'ryan@ramen.is',
        name: 'Ryan Angilly',
        id: '346656'
      }
    }

    output = @template.ramen_script_tag(ramen_settings)

    expect(output).to include("Ryan Angilly")
    expect(output).to_not include("auth_hash")
  end

  it "should calculate auth_hash correctly" do
    ts = Time.now.to_i
    ramen_settings = {
      organization_id: rand(1_000_000),
      user: {
        email: 'ryan@ramen.is',
        name: 'Ryan Angilly',
        id: '346656'
      },
      timestamp: ts
    }

    options = {organization_secret: "1234"}

    auth_hash = (Digest::SHA2.new << "ryan@ramen.is:346656:Ryan Angilly:#{ts}:1234").to_s

    output = @template.ramen_script_tag(ramen_settings, options)

    expect(output).to include("https://cdn.ramen.is/assets/ramen.js")
    expect(output).to include("Ryan Angilly")
    expect(output).to include("auth_hash")
    expect(output).to include(auth_hash)
  end

  context "with a changed asset config" do
    before :each do
      @js_uri = "http://cdn.ramen.dev/assets/ramen.js"
      RamenRails.config do |c|
        c.ramen_js_asset_uri = @js_uri
      end
    end
    
    it "should calculate auth_hash correctly" do
      ts = Time.now.to_i
      ramen_settings = {
        organization_id: rand(1_000_000),
        user: {
          email: 'ryan@ramen.is',
          name: 'Ryan Angilly',
          id: '346656'
        },
        timestamp: ts
      }

      options = {organization_secret: "1234"}

      auth_hash = (Digest::SHA2.new << "ryan@ramen.is:346656:Ryan Angilly:#{ts}:1234").to_s

      output = @template.ramen_script_tag(ramen_settings, options)

      expect(output).to include(@js_uri)
      expect(output).to include("Ryan Angilly")
      expect(output).to include("auth_hash")
      expect(output).to include(auth_hash)
    end
  end

  it "should work timestamp into hash if provided" do
    ts = Time.now.to_i
    ramen_settings = {
      timestamp: ts,
      organization_id: rand(1_000_000),
      user: {
        email: 'ryan@ramen.is',
        name: 'Ryan Angilly',
        id: '346656'
      }
    }

    options = {organization_secret: "1234"}

    not_auth_hash = (Digest::SHA2.new << "ryan@ramen.is:346656:Ryan Angilly:1234").to_s
    auth_hash = (Digest::SHA2.new << "ryan@ramen.is:346656:Ryan Angilly:#{ts}:1234").to_s

    output = @template.ramen_script_tag(ramen_settings, options)

    expect(output).to include("Ryan Angilly")
    expect(output).to include("auth_hash")
    expect(output).not_to include(not_auth_hash)
    expect(output).to include(auth_hash)
 
  end

  it "should not override auth_hash if it is provided" do
    ramen_settings = {
      organization_id: rand(1_000_000),
      user: {
        email: 'ryan@ramen.is',
        name: 'Ryan Angilly',
        id: '346656'
      },
      auth_hash: "hello"
    }

    options = {organization_secret: "1234"}

    output = @template.ramen_script_tag(ramen_settings, options)

    expect(output).to include("Ryan Angilly")
    expect(output).to include("auth_hash")
    expect(output).to include("hello")

    expect(@template.controller.instance_variable_get(RamenRails::SCRIPT_TAG_HELPER_CALLED_INSTANCE_VARIABLE)).to eq(true)
  end

end
