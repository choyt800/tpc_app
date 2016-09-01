class AddNotesToKeycardCheckouts < ActiveRecord::Migration
  def change
     add_column :keycard_checkouts, :notes, :string
  end
end
