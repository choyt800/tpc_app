class RemoveKeycardIdFromMembersTable < ActiveRecord::Migration
  def change
    remove_column :members, :keycard_id
  end
end
