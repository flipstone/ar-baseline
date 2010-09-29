require 'spec_helper'

describe ActiveRecord::Baseline do
  it "collapses to a single migration" do
    migrator.migrate
    ActiveRecord::Baseline.update baseline_configuration
    migrator.migrations.should have(1).migration
  end

  it "preserves the database structure" do
    def database_structure
      connection.tables.inject({}) do |structure, table|
        structure.merge(table => connection.table_structure(table))
      end
    end

    migrator.migrate
    old_database_structure = database_structure

    ActiveRecord::Baseline.update baseline_configuration

    recreate_database
    migrator.migrate

    database_structure.should == old_database_structure
  end

  it "preserves the data" do
    def database_data
      connection.tables.inject({}) do |structure, table|
        structure.merge(table => connection.execute("select * from #{table}"))
      end
    end

    migrator.migrate

    old_database_data = database_data

    ActiveRecord::Baseline.update baseline_configuration
    recreate_database
    migrator.migrate

    database_data.should == old_database_data
  end

  it "saves data into yaml files" do
    migrator.migrate
    ActiveRecord::Baseline.update baseline_configuration
    ["foos.yml", "bars.yml", "schema_migrations.yml"].each do |file|
      File.should exist(File.join(baseline_data_directory, file)), "#{file} doesn't exist!"
    end
  end

  it "can be run twice" do
    migrator.migrate
    ActiveRecord::Baseline.update baseline_configuration
    lambda do
      ActiveRecord::Baseline.update baseline_configuration
    end.should_not raise_error
  end

  it "will not dump data in excluded tables" do
    migrator.migrate
    ActiveRecord::Baseline.update baseline_configuration.merge(
      :exclude_table_data => [:foos]
    )

    recreate_database
    migrator.migrate
    connection.execute("select count(1) as c from foos").first["c"].to_i.should == 0
    connection.execute("select count(1) as c from bars").first["c"].to_i.should > 0
  end
end
