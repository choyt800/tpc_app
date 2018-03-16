class MailService < ActiveRecord::Base
  belongs_to :member
  belongs_to :team
  belongs_to :mailbox
  belongs_to :plan

  def status
    if end_date? && Date.current <= end_date
      "pending cancellation"
    elsif end_date?
      "cancelled"
    else
      "live"
    end
  end

  def pretty_invoice_amount
    return 'n/a' unless invoice_amount
    '$' + '%.2f' % (invoice_amount / 100.0)
  end
end
