class AddStartDateToMembers < ActiveRecord::Migration
  def change
     add_column :members, :start_date, :datetime
     add_column :members, :payment_type, :string
     add_column :members, :has_mail_service, :boolean
  end
end
