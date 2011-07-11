class AddIssuePosition < ActiveRecord::Migration

  def self.up
    add_column :issues, :position_for_user, :integer, :default => nil
    add_column :issues, :position_for_project, :integer, :default => nil
  end

  def self.down
    remove_column :issues, :position_for_user
    remove_column :issues, :position_for_project
  end

end
