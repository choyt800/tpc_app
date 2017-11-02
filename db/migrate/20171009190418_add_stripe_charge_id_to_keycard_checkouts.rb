class AddStripeChargeIdToKeycardCheckouts < ActiveRecord::Migration
  def change
    add_column :keycard_checkouts, :stripe_charge_id, :string
    add_column :keycard_checkouts, :stripe_charge_refunded, :boolean, default: false
  end
end
