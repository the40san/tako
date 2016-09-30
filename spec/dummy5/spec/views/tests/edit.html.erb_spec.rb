require 'rails_helper'

RSpec.describe "tests/edit", type: :view do
  before(:each) do
    @test = assign(:test, Test.create!())
  end

  it "renders the edit test form" do
    render

    assert_select "form[action=?][method=?]", test_path(@test), "post" do
    end
  end
end
