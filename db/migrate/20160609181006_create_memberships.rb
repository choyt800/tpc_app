class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.string :membership_type
      t.datetime :start_date
      t.datetime :end_date
      t.integer :plan_id
      t.integer :member_id
      t.timestamps null: false
    end
  end
end
