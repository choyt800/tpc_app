class AddAttachmentDocumentToMembers < ActiveRecord::Migration
  def self.up
    change_table :members do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :members, :document
  end
end
