class CustomSubscription < ActiveRecord::Base
  belongs_to :member
  belongs_to :team
  belongs_to :plan

  validates :member_id, presence: true, unless: :team_id
  validates :team_id, presence: true, unless: :member_id
  attr_accessor :quantity, :plan_id, :plan_category_id, :trial_period_days, :coupon, :prorate, :charge_now

  def status
    if end_date? && Time.now <= end_date
      "pending cancellation"
    elsif end_date?
      "cancelled"
    elsif start_date? && Time.now < start_date
      "trialling"
    else
      "live"
    end
  end

  def pretty_invoice_amount
    return 'n/a' unless invoice_amount
    '$' + '%.2f' % (invoice_amount / 100.0)
  end

  def self.pretty_invoice_amount(invoice_amount)
    return 'n/a' unless invoice_amount
    '$' + '%.2f' % (invoice_amount / 100.0)
  end

  # Preview Invoice
  def self.preview_subscription(customer_id, items, coupon = nil)
    Stripe::Invoice.upcoming(
      customer: customer_id,
      subscription_items: items,
      coupon: coupon
    )
  end

  def self.preview_subscription_update(customer_id, subscription_id, items, coupon = nil, prorate, charge_now)
    Stripe::Invoice.upcoming(
      customer: customer_id,
      subscription: subscription_id,
      subscription_items: items,
      coupon: coupon,
      subscription_prorate: prorate,
      subscription_proration_date: (prorate ? Time.now.midnight.to_i : nil)
    )
  end

  # Create Sub, save Sub ID
  def self.create_subscription(customer_id, items, coupon = nil, trial_period_days = nil)
    Stripe::Subscription.create(
      customer: customer_id,
      items: items,
      coupon: coupon,
      trial_period_days: trial_period_days
    )
  end

  # Pull upcoming Invoice
  def self.upcoming_invoice(customer_id, subscription_id)
    Stripe::Invoice.upcoming(
      customer: customer_id,
      subscription: subscription_id
    )
  end
end
