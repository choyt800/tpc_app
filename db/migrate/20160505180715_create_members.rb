class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name
      t.string :last_name
      t.string :email_string
      t.text :notes

      t.timestamps null: false
    end
  end
end
