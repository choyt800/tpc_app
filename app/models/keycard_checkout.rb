class KeycardCheckout < ActiveRecord::Base
  belongs_to :member
  belongs_to :keycard
  belongs_to :plan

  validates :member_id, presence: true
  validates :start_date, presence: true

  accepts_nested_attributes_for :keycard

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
