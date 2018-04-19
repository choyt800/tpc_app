class CustomSubscriptionsController < ApplicationController
  before_action :set_member_or_team, except: [:index, :preview, :preview_update]
  before_action :set_custom_subscription, only: [:show, :edit, :update, :destroy, :cancel]

  def index
  end

  def show
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

      @custom_subscription.start_date = Time.at(subscription.created)
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

  def edit
    @coupons = Stripe::Coupon.list(limit: 50)
    @all_plans = Plan.all.to_json
    @latest_invoice = Stripe::Invoice.list(subscription: @custom_subscription.stripe_sub_id, limit: 1).first

    @line_items = @stripe_subscription.items.data

    @selected_coupon = @stripe_subscription.discount ? @stripe_subscription.discount.coupon.id : nil
  end

  def preview_update
    stripe_line_items = line_items(params['custom_subscription']['line_items'])
    coupon = params['custom_subscription']['coupon'].presence || nil

    current_subscription = Stripe::Subscription.retrieve(params[:stripe_subscription_id])

    prorate = custom_subscription_params['prorate'] == '1'
    charge_now = custom_subscription_params['charge_now'] == '1'

    preview = CustomSubscription.preview_subscription_update(params[:member_stripe_id], params[:stripe_subscription_id],
                stripe_line_items, coupon, prorate, charge_now)

    if prorate
      real_total = CustomSubscription.preview_subscription_update(params[:member_stripe_id], params[:stripe_subscription_id],
        stripe_line_items, coupon, false, charge_now).total
    end

    render json: preview.to_hash.merge({real_total: real_total})
  end

  def update
    stripe_line_items = line_items(params['custom_subscription']['line_items'])
    prorate = custom_subscription_params['prorate'] == '1'
    proration_date = Time.now.midnight.to_i

    @stripe_subscription.items = stripe_line_items
    @stripe_subscription.prorate = prorate
    @stripe_subscription.proration_date = proration_date if prorate

    respond_to do |format|
      if @stripe_subscription.save
        next_invoice = CustomSubscription.upcoming_invoice(@member.stripe_id, @custom_subscription.stripe_sub_id)
        @custom_subscription.update_attributes!(invoice_amount: next_invoice.total)

        format.html { redirect_to @member, notice: 'Custom subscription was successfully updated.' }
        format.json { render :show, status: :updated, location: @custom_subscription }
      else
        format.html { render :new }
        format.json { render json: @custom_subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel
    ActiveRecord::Base.transaction do
      @stripe_subscription.delete(at_period_end: true)
      @end_date = @stripe_subscription.current_period_end

      @custom_subscription.end_date = Time.at(@end_date).to_date
      @custom_subscription.next_invoice_date = nil
      @custom_subscription.save!

      respond_to do |format|
        format.html { redirect_to @member, notice: 'Subscription was successfully canceled.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_custom_subscription
      @custom_subscription = CustomSubscription.find(params[:id])
      @stripe_subscription = Stripe::Subscription.retrieve(@custom_subscription.stripe_sub_id)
    end

    def set_member_or_team
      @member = params[:member_id] ? Member.find(params[:member_id]) : Team.find(params[:team_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def custom_subscription_params
      params.require(:custom_subscription).permit(:line_items, :coupon, :prorate, :charge_now)
    end

    def line_items(params)
      stripe_sub_items = []
      params.each do |line_item|
        if line_item.last['quantity'].present? && line_item.last['quantity'] == '0'
          stripe_sub_items << {
            id: line_item.last['subscription_item'],
            deleted: true
          }
        elsif line_item.last['quantity'].present? && line_item.last['plan_id'].present?
          stripe_sub_items << {
            plan: Plan.find(line_item.last['plan_id']).stripe_id,
            quantity: line_item.last['quantity']
          }.merge(line_item.last['subscription_item'] ? {id: line_item.last['subscription_item']} : {})
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
