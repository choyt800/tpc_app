class AddStripeDataToMembershipsAndMailServices < ActiveRecord::Migration
  def change
    add_column :memberships, :stripe_sub_id, :string
    add_column :memberships, :invoice_amount, :integer
    add_column :mail_services, :stripe_sub_id, :string
    add_column :mail_services, :invoice_amount, :integer
  end
end
