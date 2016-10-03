require 'rails_helper'

RSpec.describe "tests/index", type: :view do
  before(:each) do
    assign(:tests, [
      Test.create!(),
      Test.create!()
    ])
  end

  it "renders a list of tests" do
    render
  end
end
