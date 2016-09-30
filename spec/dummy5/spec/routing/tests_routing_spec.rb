require "rails_helper"

RSpec.describe TestsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/tests").to route_to("tests#index")
    end

    it "routes to #new" do
      expect(:get => "/tests/new").to route_to("tests#new")
    end

    it "routes to #show" do
      expect(:get => "/tests/1").to route_to("tests#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/tests/1/edit").to route_to("tests#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/tests").to route_to("tests#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/tests/1").to route_to("tests#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/tests/1").to route_to("tests#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/tests/1").to route_to("tests#destroy", :id => "1")
    end

  end
end
