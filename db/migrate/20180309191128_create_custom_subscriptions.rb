class CreateCustomSubscriptions < ActiveRecord::Migration
  def change
    create_table :custom_subscriptions do |t|
      t.integer   :member_id
      t.integer   :team_id
      t.string    :stripe_id
      t.datetime  :next_invoice_date
      t.text      :notes
    end
  end
end
