class AddAverageMonthlyPaymentToMailServices < ActiveRecord::Migration
  def change
    add_column :mail_services, :average_monthly_payment, :decimal
  end
end
