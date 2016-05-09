class AddKeycardIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :keycard_id, :integer
  end
end
