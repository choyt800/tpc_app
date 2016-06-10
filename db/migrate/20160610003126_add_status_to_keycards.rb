class AddStatusToKeycards < ActiveRecord::Migration
  def change
    add_column :keycards, :status, :string
  end
end
