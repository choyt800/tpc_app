class RemovePaymentTypeFromMembership < ActiveRecord::Migration
  def change
    remove_column :memberships, :payment_type
    remove_column :memberships, :datetime
  end
end
