gem "activerecord", :version => ">= 2.3.8"
require 'active_record'

module ActiveRecord
  autoload :Baseline, 'ar-baseline/baseline'
end
