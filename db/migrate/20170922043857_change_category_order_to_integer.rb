class ChangeCategoryOrderToInteger < ActiveRecord::Migration
  def change
    change_column :plans, :category_order, :integer
  end
end
