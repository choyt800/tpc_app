class AddDayToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :day, :string
  end
end
