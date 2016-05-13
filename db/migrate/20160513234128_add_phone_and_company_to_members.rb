class AddPhoneAndCompanyToMembers < ActiveRecord::Migration
  def change
    add_column :members, :phone, :string
    add_column :members, :company, :string
  end
end
