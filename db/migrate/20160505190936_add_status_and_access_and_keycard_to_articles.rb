class AddStatusAndAccessAndKeycardToArticles < ActiveRecord::Migration
  def change
    add_column :members, :status, :string
    add_column :members, :access, :string
    add_column :members, :keycard, :string
  end
end
