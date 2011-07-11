class AddQueryPosition < ActiveRecord::Migration

  def self.up
    add_column :queries, :position, :integer, :default => nil
  end

  def self.down
    remove_column :queries, :position
  end

end
