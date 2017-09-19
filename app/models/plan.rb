class Plan < ActiveRecord::Base
  belongs_to :plan_category
  has_many :memberships
  has_many :keycard_checkouts
  has_many :mail_services
  before_create :create_stripe_plan
  before_update :update_stripe_plan

  attr_accessor :stripe_amount, :stripe_interval, :stripe_interval_count, :stripe_trial_period_days
  default_scope { order(:category_order) }
  scope :mail_service, -> { where(plan_category_id: PlanCategory.find_by_name('Mail Service').id) }
  scope :misc, -> { where(plan_category_id: PlanCategory.find_by_name('Misc').id) }

  def assign_params_from_controller(params)
    @params = params
  end

  def create_stripe_plan
    Stripe::Plan.create(
      id: @params[:stripe_id],
      name: @params[:name],
      amount: (@params[:stripe_amount].to_f * 100).to_i,
      currency: 'usd',
      interval_count: @params[:stripe_interval_count],
      interval: @params[:stripe_interval],
      trial_period_days: @params[:stripe_trial_period_days]
    )
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
end
