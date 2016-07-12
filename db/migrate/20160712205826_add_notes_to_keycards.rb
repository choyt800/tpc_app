class AddNotesToKeycards < ActiveRecord::Migration
  def change
    add_column :keycards, :notes, :text
  end
end
