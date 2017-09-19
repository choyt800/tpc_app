class AddNextInvoiceDate < ActiveRecord::Migration
  def change
    add_column :memberships, :next_invoice_date, :datetime
    add_column :mail_services, :next_invoice_date, :datetime
    add_column :keycard_checkouts, :next_invoice_date, :datetime
  end
end
