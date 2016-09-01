class CreateMailboxes < ActiveRecord::Migration
  def change
    create_table :mailboxes do |t|
      t.integer :number

      t.timestamps null: false
    end
  end
end
