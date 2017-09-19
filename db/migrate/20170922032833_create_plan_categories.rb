class CreatePlanCategories < ActiveRecord::Migration
  def change
    create_table :plan_categories do |t|
      t.string :name
      t.string :plan_order

      t.timestamps null: false
    end

    add_column :plans, :plan_category_id, :string
  end
end
