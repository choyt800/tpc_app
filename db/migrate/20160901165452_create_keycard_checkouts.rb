class CreateKeycardCheckouts < ActiveRecord::Migration
  def change
    create_table :keycard_checkouts do |t|
 
      t.datetime :start_date
      t.datetime :end_date
      t.integer :keycard_id
      t.integer :member_id
      t.timestamps null: false

    end
  end
end
