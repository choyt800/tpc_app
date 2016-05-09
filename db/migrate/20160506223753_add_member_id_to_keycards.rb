class AddMemberIdToKeycards < ActiveRecord::Migration
  def change
    add_column :keycards, :member_id, :integer
  end
end
