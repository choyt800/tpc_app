class AddEnddateAndPaymentTypeToMemberships < ActiveRecord::Migration
  def change
    remove_column :memberships, :end_date, :datetime
    remove_column :memberships, :payment_type, :string
    add_column :memberships, :end_date, :datetime
    add_column :memberships, :payment_type, :string


  end
end
