class AddItemsToCustomSubscription < ActiveRecord::Migration
  def change
    add_column :custom_subscriptions, :items, :string
    add_column :custom_subscriptions, :payment_type, :string, default: 'stripe'
  end
end
