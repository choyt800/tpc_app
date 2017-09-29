class MailService < ActiveRecord::Base
  belongs_to :member
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
end
