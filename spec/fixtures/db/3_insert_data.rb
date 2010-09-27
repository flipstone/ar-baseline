class InsertData < ActiveRecord::Migration
  def self.up
    execute "insert into foos (name) values ('foo_1')"
    execute "insert into foos (name) values ('foo_2')"

    execute "insert into bars (name) values ('bar_1')"
    execute "insert into bars (name) values ('bar_2')"
  end

  def self.down
    execute "delete from foos"
    execute "delete from bars"
  end
end
