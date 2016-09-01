class DropMailboxes < ActiveRecord::Migration
  def change
     drop_table :mailboxes
  end
end
