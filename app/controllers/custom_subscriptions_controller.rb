class CustomSubscriptionsController < ApplicationController
  before_action :set_member_or_team, except: [:index, :preview]
  before_action :set_custom_subscription, only: [:show, :edit, :update, :destroy, :cancel]

  def index
  end

  def show
    @stripe_subscription = Stripe::Subscription.retrieve(@custom_subscription.stripe_sub_id)
  end

  def new
    @custom_subscription = @member.custom_subscriptions.build
    @start_date = Date.current
    @line_items = []
    @all_plans = Plan.all.to_json

    @coupons = Stripe::Coupon.list(limit: 50)
  end

  def preview
    stripe_line_items = line_items(params['custom_subscription']['line_items'])
    coupon = params['custom_subscription']['coupon'].presence || nil
    preview = CustomSubscription.preview_subscription(params[:member_stripe_id], stripe_line_items, coupon)

    render json: preview
  end

  def create
    ActiveRecord::Base.transaction do
      @custom_subscription = @member.custom_subscriptions.build

      stripe_line_items = line_items(params['custom_subscription']['line_items'])
      coupon = params['custom_subscription']['coupon'].presence || nil
      trial_period_days = set_trial_period_days
      preview = CustomSubscription.preview_subscription(params[:member_stripe_id], stripe_line_items, coupon)
      subscription = CustomSubscription.create_subscription(params[:member_stripe_id], stripe_line_items, coupon, trial_period_days)

      @custom_subscription.stripe_sub_id = subscription.id
      @custom_subscription.next_invoice_date = Time.at(subscription.current_period_end)
      @custom_subscription.invoice_amount = preview.amount_due

      respond_to do |format|
        if @custom_subscription.save!
          format.html { redirect_to @member, notice: 'Custom subscription was successfully created.' }
          format.json { render :show, status: :created, location: @custom_subscription }
        else
          format.html { render :new }
          format.json { render json: @custom_subscription.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_custom_subscription
      @custom_subscription = CustomSubscription.find(params[:id])
    end

    def set_member_or_team
      @member = params[:member_id] ? Member.find(params[:member_id]) : Team.find(params[:team_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def custom_subscription_params
      params.require(:custom_subscription).permit(:line_items, :coupon)
    end

    def line_items(params)
      stripe_sub_items = []
      params.each do |line_item|
        if line_item.last['quantity'].present? && line_item.last['plan_id'].present?
          stripe_sub_items << {
            plan: Plan.find(line_item.last['plan_id']).stripe_id,
            quantity: line_item.last['quantity']
          }
        end
      end
      return stripe_sub_items
    end

    def set_trial_period_days
      trial_end = params['custom_subscription']['trial_period_days']
      if trial_end == Date.current.to_s(:d)
        return nil
      else
        (Date.parse(trial_end) - Date.current).to_i
      end
    end
end
