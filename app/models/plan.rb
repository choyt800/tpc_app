class Plan < ActiveRecord::Base
  belongs_to :plan_category
  has_many :memberships
  has_many :keycard_checkouts
  has_many :mail_services
  before_create :create_stripe_plan
  before_update :update_stripe_plan

  attr_accessor :dollar_amount
  default_scope { where(deleted: false).order(:category_order) }
  scope :memberships, -> { where('plan_category_id IN (?)', [PlanCategory.find_by_name('Resident Access').id, PlanCategory.find_by_name('Community Access').id, PlanCategory.find_by_name('Private Office').id])}
  scope :mail_service, -> { where(plan_category_id: PlanCategory.find_by_name('Mail Service').id) }
  scope :misc, -> { where(plan_category_id: PlanCategory.find_by_name('Misc').id) }

  def as_json(options={})
    super(only: [:id, :stripe_id, :interval, :interval_count, :amount, :pretty_display], methods: :pretty_display)
  end

  def assign_params_from_controller(params)
    @params = params
    self.amount = dollars_to_cents
  end

  def create_stripe_plan
    p = Stripe::Plan.create(
      name: @params[:name],
      amount: amount,
      currency: 'usd',
      interval_count: @params[:interval_count],
      interval: @params[:interval],
      trial_period_days: @params[:trial_period_days]
    )

    self.stripe_id = p.id
  end

  def update_stripe_plan
    if self.stripe_id && self.name_changed?
      p = Stripe::Plan.retrieve(self.stripe_id)
      p.name = self.name
      p.save
    end
  end

  def categories
    [
      'Designated Desk',
      'Communal Membership',
      'Team Membership',
      'Mail Service',
      'Misc'
    ]
  end

  def dollars_to_cents
    (dollar_amount.to_f * 100).to_i
  end

  def pretty_amount
    '%.2f' % (amount / 100.0) if amount
  end

  def pretty_interval
    return '' unless interval && interval_count

    if interval_count == 1
      return "/ #{interval}"
    else
      return "every #{ActionController::Base.helpers.pluralize(interval_count, interval)}"
    end
  end

  def pretty_display
    return '' unless interval && interval_count

    "$#{pretty_amount} #{pretty_interval}"
  end
end
