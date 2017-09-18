class AddStripeIdsAndCategories < ActiveRecord::Migration
  def change
    add_column :members, :stripe_id, :string
    add_column :plans, :stripe_id, :string
    add_column :plans, :category, :string
    add_column :plans, :category_order, :string
  end
end
