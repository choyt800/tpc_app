class RemovePlanColumns < ActiveRecord::Migration
  def change
    remove_column :plan_categories, :plan_order
    remove_column :plans, :category
  end
end
