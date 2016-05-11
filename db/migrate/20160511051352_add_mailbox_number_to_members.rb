class AddMailboxNumberToMembers < ActiveRecord::Migration
  def change
    add_column :members, :mailbox_number, :string
  end
end
