class AddMembershipTypeToMembers < ActiveRecord::Migration
  def change
    add_column :members, :membership_type, :string
  end
end
