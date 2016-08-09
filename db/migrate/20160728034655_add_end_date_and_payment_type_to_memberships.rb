class AddEndDateAndPaymentTypeToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :end_date, :datetime
    add_column :memberships, :payment_type, :string
  end
end
