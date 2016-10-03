require 'rails_helper'

RSpec.describe "Tests", type: :request do
  describe "GET /tests" do
    it "works! (now write some real specs)" do
      get tests_path
      expect(response).to have_http_status(200)
    end
  end
end
