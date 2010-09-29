if defined?(namespace) == "method" && defined?(task) == "method"
  namespace :db do
    namespace :baseline do
      task :update => :environment do
        ActiveRecord::Baseline.update
      end
    end
  end
end
