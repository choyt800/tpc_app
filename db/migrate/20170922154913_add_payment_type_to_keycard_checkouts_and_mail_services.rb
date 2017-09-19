class AddPaymentTypeToKeycardCheckoutsAndMailServices < ActiveRecord::Migration
  def change
    add_column :keycard_checkouts, :payment_type, :string
    add_column :mail_services, :payment_type, :string
  end
end
