class AddLastChangeDateToMembers < ActiveRecord::Migration
  def change
    add_column :members, :last_change_date, :datetime
  end
end
