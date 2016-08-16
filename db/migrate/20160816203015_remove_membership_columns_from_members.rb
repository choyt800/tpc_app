class RemoveMembershipColumnsFromMembers < ActiveRecord::Migration
   def change
    remove_column :members, :membership_type
    remove_column :members, :access
    remove_column :members, :start_date 
    remove_column :members, :payment_type
   end
end
