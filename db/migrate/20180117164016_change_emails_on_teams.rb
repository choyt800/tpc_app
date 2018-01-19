class ChangeEmailsOnTeams < ActiveRecord::Migration
  def change
    add_column :teams, :member_email, :string
    rename_column :teams, :owner_email, :billing_email
  end
end
