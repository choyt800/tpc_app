class RenameEmailInMembers < ActiveRecord::Migration
  def change
    rename_column :members, :email_string, :email
  end
end
