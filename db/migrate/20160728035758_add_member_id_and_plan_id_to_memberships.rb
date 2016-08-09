class AddMemberIdAndPlanIdToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :member_id, :integer
    add_column :memberships, :plan_id, :integer
  end
end
