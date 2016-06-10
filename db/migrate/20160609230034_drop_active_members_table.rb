class DropActiveMembersTable < ActiveRecord::Migration
  def change
    def down
      drop_table :active_members
    end
  end
end
