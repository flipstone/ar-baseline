module MigrationReloadHack

end

module ActiveRecord
  class MigrationProxy

    private

      def load_migration
        # DV change require to load so that new versions of the migration
        # class will get picked up as it changes over test runs
        load(File.expand_path(filename))
        name.constantize
      end

  end
end
