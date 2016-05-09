class DropKeycardFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :keycard
  end
end
