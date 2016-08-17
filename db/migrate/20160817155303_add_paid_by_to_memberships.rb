class AddPaidByToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :paid_by, :string
  end
end
