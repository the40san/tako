require "spec_helper"
require "rake"

describe "Rake tasks" do
  before(:all) do
    Rake.application.rake_require "tako/railties/databases"
    Rails.application.load_tasks
  end
  describe "db:tako:migrate" do
    before do
      Rake::Task["db:tako:migrate"].reenable
    end
    it "works" do
      Rake::Task["db:tako:migrate"].invoke
    end
  end
end
