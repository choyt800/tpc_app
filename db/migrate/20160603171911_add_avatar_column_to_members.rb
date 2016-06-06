class AddAvatarColumnToMembers < ActiveRecord::Migration
  def self.up
    change_table :members do |t|
      t.has_attached_file :avatar
    end
  end

  def self.down
    drop_attached_file :members, :avatar
  end
end
