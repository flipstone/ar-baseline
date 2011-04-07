require 'stringio'
require 'fileutils'

module ActiveRecord
  class Baseline
    class <<self
      attr_accessor :configuration
    end

    ROOT = defined?(Rails.root) ? [Rails.root] : []

    DEFAULT_CONFIGURATION = {
      :migrations_directory => File.join(ROOT + %w(db migrate)),
      :baseline_data_directory => File.join(ROOT + %w(db baseline)),
      :connection_class_name => "ActiveRecord::Base",
      :verbose => true
    }

    self.configuration = DEFAULT_CONFIGURATION.dup

    def self.update(configuration = Baseline.configuration)
      new(configuration).update
    end

    attr_reader :configuration

    def initialize(configuration = Baseline.configuration)
      @configuration = configuration
    end

    def migrations_directory
      configuration[:migrations_directory]
    end

    def baseline_data_directory
      configuration[:baseline_data_directory]
    end

    def connection
      @connection ||= configuration[:connection_class_name].constantize.connection
    end

    def say(s)
      puts s if configuration[:verbose]
    end

    def update
      say "Deleting old data files..."
      delete_old_data_files
      say "Dumping new data files..."
      dump_new_data_files
      say "Deleting old migrations..."
      delete_old_migrations
      say "Creating #{baseline_migration_file}..."
      create_baseline_migration
      say "Done!"
    end

    def baseline_data_file(table_name)
      File.join(baseline_data_directory, table_name + ".yml")
    end

    def delete_old_data_files
      Dir[baseline_data_file('*')].each do |f|
        File.unlink f
      end
    end

    def dump_new_data_files
      FileUtils.mkdir_p baseline_data_directory

      excluded_tables = configuration[:exclude_table_data] || []
      tables = connection.tables - excluded_tables.map(&:to_s)

      tables.each do |table|
        rows = connection.select_all("SELECT * FROM #{connection.quote_table_name(table)}")
        if rows.any?
          columns = connection.columns(table)

          File.open(baseline_data_file(table), 'w') do |yaml_io|
            rows_to_dump = rows.reject do |row|
              # don't insert our migration version, as it will break db:migrate
              table == "schema_migrations" && row["version"] == migrator.current_version.to_s
            end

            YAML.dump rows_to_dump, yaml_io
          end
        end
      end
    end

    def create_baseline_migration
      File.open(baseline_migration_file, 'w') do |f|
        f << baseline_migration_source
      end
      sleep 20
    end

    def baseline_migration_file
      File.join migrations_directory, "#{migrator.current_version}_baseline.rb"
    end

    def baseline_migration_source
      <<-end_src
class Baseline < ActiveRecord::Migration
  def self.up
#{create_tables_source}
  #{insert_records_source}
  end
end
      end_src
    end

    def create_tables_source
      stream = StringIO.new
      SchemaDumper.send(:new,connection).send(:tables, stream)
      stream.string
    end

    def insert_records_source
      "::ActiveRecord::Baseline.new(#{configuration.inspect}).insert_baseline_data"
    end

    def insert_baseline_data
      Dir[baseline_data_file('*')].each do |data_file|
        table_name = File.basename(data_file, '.yml')
        columns = connection.columns(table_name).index_by(&:name)

        YAML.load_file(data_file).each do |row|
          column_names, values = row.inject([[],[]]) do |(cs, vs), (column, value)|
            [cs + [connection.quote_column_name(column)],
             vs + [connection.quote(row[column], columns[column])]]
          end

          connection.execute "INSERT INTO #{connection.quote_table_name(table_name)} (#{column_names.join(',')}) VALUES (#{values.join(',')})"
        end
      end
    end

    def delete_old_migrations
      migrator.migrations.each do |f|
        if migrator.migrated.include?(f.version.to_i)
          File.unlink f.filename
        end
      end
    end

    def migrator
      @migrator ||= ActiveRecord::Migrator.new(nil, migrations_directory, nil)
    end
  end
end
