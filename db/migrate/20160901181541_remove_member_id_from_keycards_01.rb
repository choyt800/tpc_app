class RemoveMemberIdFromKeycards01 < ActiveRecord::Migration
  def change
    remove_column :keycards, :member_id
  end
end
