class Plan < ActiveRecord::Base
  has_many :memberships
  before_create :create_stripe_plan
  before_update :update_stripe_plan

  attr_accessor :stripe_amount, :stripe_interval, :stripe_interval_count, :stripe_trial_period_days

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
      'Designated Desks',
      'Communal Memberships',
      'Team Memberships',
      'Mail Service',
      'Misc'
    ]
  end
end
