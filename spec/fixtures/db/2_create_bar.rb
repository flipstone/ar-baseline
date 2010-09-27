class CreateBar < ActiveRecord::Migration
  def self.up
    create_table :bars do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :bars
  end
end
