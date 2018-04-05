class AddTimestampsToCustomSubscriptions < ActiveRecord::Migration
  def up
    change_table :custom_subscriptions do |t|
      t.timestamps
    end
  end

  def down
    remove_column :custom_subscriptions, :created_at
    remove_column :custom_subscriptions, :updated_at
  end
end
