class AddDatesToCustomSubscriptions < ActiveRecord::Migration
  def change
    add_column :custom_subscriptions, :start_date, :datetime
    add_column :custom_subscriptions, :end_date, :datetime
  end
end
