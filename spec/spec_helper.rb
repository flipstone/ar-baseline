require 'rubygems'
require 'ar-baseline'
require 'fileutils'
require 'logger'

gem 'sqlite3-ruby', :version => ">= 1.2.4"

ActiveRecord::Base.logger = Logger.new("tmp/spec.log")

ActiveRecord::Migration.verbose = false

ENV['SPEC_DB'] = SPEC_DB = File.expand_path("tmp/spec_db.sqlite")

RSpec.configure do |config|
  Dir[
    File.join(File.dirname(__FILE__), %w(helpers *.rb))
  ].each do |helper_file|
    require_relative helper_file
    config.include File.basename(helper_file, '.rb').classify.constantize
  end

  config.before(:each) do
    reset_fixtures
    recreate_database
  end
end

