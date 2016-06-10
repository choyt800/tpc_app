class DropActiveMembersTable1 < ActiveRecord::Migration
   def change
    def up
      drop_table :active_members
    end
  end
end
