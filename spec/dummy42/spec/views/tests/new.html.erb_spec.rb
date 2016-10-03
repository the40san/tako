require 'rails_helper'

RSpec.describe "tests/new", type: :view do
  before(:each) do
    assign(:test, Test.new())
  end

  it "renders new test form" do
    render

    assert_select "form[action=?][method=?]", tests_path, "post" do
    end
  end
end
