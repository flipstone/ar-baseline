class CreateFoo < ActiveRecord::Migration
  def self.up
    create_table :foos do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :foos
  end
end
