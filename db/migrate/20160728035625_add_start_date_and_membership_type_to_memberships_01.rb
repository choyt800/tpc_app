class AddStartDateAndMembershipTypeToMemberships01 < ActiveRecord::Migration
  def change
    add_column :memberships, :start_date, :datetime
    add_column :memberships, :membership_type, :string
  end
end
