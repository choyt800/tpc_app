class AddAverageMonthlyPaymentToMemberships < ActiveRecord::Migration
  def change
      add_column :memberships, :average_monthly_payment, :decimal
  end
end
