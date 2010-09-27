require 'rubygems'
require 'ar-baseline'
require 'fileutils'

gem 'sqlite3-ruby', :version => ">= 1.2.4"

ActiveRecord::Base.logger = Logger.new("tmp/spec.log")

ActiveRecord::Migration.verbose = false

SPEC_DB = "tmp/spec_db.sqlite"

Spec::Runner.configure do |config|
  Dir['spec/helpers/*.rb'].each do |helper_file|
    require helper_file
    config.include File.basename(helper_file, '.rb').classify.constantize
  end

  config.before(:each) do
    reset_fixtures
    recreate_database
  end
end

