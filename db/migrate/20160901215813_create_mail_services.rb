class CreateMailServices < ActiveRecord::Migration
  def change
    create_table :mail_services do |t|
      t.integer :member_id
      t.integer :mailbox_id
      t.datetime :start_date
      t.datetime :end_date
      t.text :notes

      t.timestamps null: false
    end
  end
end
