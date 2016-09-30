require 'rails_helper'

RSpec.describe "tests/show", type: :view do
  before(:each) do
    @test = assign(:test, Test.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
