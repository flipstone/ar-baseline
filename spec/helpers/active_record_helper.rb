module ActiveRecordHelper
  def recreate_database
    File.delete(SPEC_DB) if File.exist?(SPEC_DB)
    ActiveRecord::Base.establish_connection(
        :adapter => "sqlite3",
        :database  => SPEC_DB
    )
  end

  def connection
    ActiveRecord::Base.connection
  end

  def migrator
    ActiveRecord::Migrator.new(:up, migrations_directory, nil)
  end

  def baseline_configuration
    ActiveRecord::Baseline::DEFAULT_CONFIGURATION.merge(
      :migrations_directory => migrations_directory,
      :baseline_data_directory => baseline_data_directory,
      :verbose => false
    )
  end

  def migrations_directory
    fixture_path('db/migrate')
  end

  def baseline_data_directory
    fixture_path('db/baseline')
  end
end

