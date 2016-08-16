class RemoveMembershipTypeFromMemberships < ActiveRecord::Migration
  def change
    remove_column :memberships, :membership_type
  end
end
