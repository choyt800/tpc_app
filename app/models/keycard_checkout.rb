class KeycardCheckout < ActiveRecord::Base
  belongs_to :member
  belongs_to :team
  belongs_to :keycard
  belongs_to :plan

  validates :member_id, presence: true, unless: :team_id
  validates :team_id, presence: true, unless: :member_id
  validates :start_date, presence: true

  accepts_nested_attributes_for :keycard

  attr_accessor :deposit, :refund

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
