class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :status
      t.text :notes

      t.timestamps null: false
    end
  end
end
