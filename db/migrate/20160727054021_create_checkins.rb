class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.datetime :date
      t.integer :member_id

      t.timestamps null: false
    end
  end
end
