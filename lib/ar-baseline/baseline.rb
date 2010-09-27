require 'stringio'

module ActiveRecord
  class Baseline
    def self.update(migrations_directory, connection=ActiveRecord::Base.connection)
      new(migrations_directory, connection).update
    end

    attr_reader :migrations_directory, :connection

    def initialize(migrations_directory, connection)
      @migrations_directory, @connection = migrations_directory, connection
    end

    def update
      delete_old_migrations
      create_baseline_migration
    end

    def create_baseline_migration
      File.open(baseline_migration_file, 'w') do |f|
        f << baseline_migration_source
      end
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
      src = []
      connection.tables.each do |table|
        columns = connection.columns(table)
        connection.execute("SELECT * FROM #{connection.quote_table_name(table)}").each do |row|
          # don't insert our migration version, as it will break db:migrate
          next if table == "schema_migrations" && row["version"] == migrator.current_version.to_s

          values = columns.inject([]) do |vs, column|
            vs + [connection.quote(row[column.name], column)]
          end

          column_names = columns.map {|c| connection.quote_column_name(c.name)}.join(',')
          src << "execute('INSERT INTO #{q connection.quote_table_name(table)} (#{q column_names}) VALUES (#{q values.join(',')})')"
        end
      end
      src.join("\n")
    end

    def q(s)
      s.gsub("'", "\\\\'")
    end

    def delete_old_migrations
      migrator.migrations.each do |f|
        File.unlink f.filename
      end
    end

    def migrator
      @migrator ||= ActiveRecord::Migrator.new(nil, migrations_directory, nil)
    end
  end
end
