class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.string :type
      t.string :start_date
      t.string :datetime

      t.timestamps null: false
    end
  end
end
