require 'spec_helper'

describe "rake tasks" do
  it "succeeds" do
    migrator.migrate

    lib_dir = File.expand_path(File.join(File.dirname(__FILE__), %w(.. lib)))

    command = "cd '#{fixture_path("db")}' && rake --trace -I '#{lib_dir}' db:baseline:update 2>&1"
    output = `#{command}`
    $?.should be_success, command + "\n" + output

    recreate_database
    migrator.migrate
    migrator.migrations.should have(1).migration

    output.should =~ /Deleting old data files.../
    output.should =~ /Dumping new data files.../
    output.should =~ /Deleting old migrations.../
    output.should =~ /Creating db\/migrate\/3_baseline.rb.../
    output.should =~ /Done!/
  end
end
