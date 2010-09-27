require 'spec_helper'

describe ActiveRecord::Baseline do
  it "preserves the database structure" do
    def database_structure
      connection.tables.inject({}) do |structure, table|
        structure.merge(table => connection.table_structure(table))
      end
    end

    migrator.migrate
    old_database_structure = database_structure

    ActiveRecord::Baseline.update migrations_directory

    recreate_database
    migrator.migrate

    database_structure.should == old_database_structure
  end

  it "collapases to a single migration" do
    migrator.migrate
    ActiveRecord::Baseline.update migrations_directory
    migrator.migrations.should have(1).migration
  end
end
