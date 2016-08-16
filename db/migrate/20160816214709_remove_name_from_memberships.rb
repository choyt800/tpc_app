class RemoveNameFromMemberships < ActiveRecord::Migration
  def change
    remove_column :memberships, :name
  end
end
