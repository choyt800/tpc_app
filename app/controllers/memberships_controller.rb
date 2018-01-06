class MembershipsController < ApplicationController
  before_action :set_member, except: [:index]
  before_action :set_membership, only: [:show, :edit, :update, :destroy, :cancel]


  # GET /memberships
  # GET /memberships.json
  def index
    @memberships = Membership.all.order('lower(paid_by) ASC')
  end

  # GET /memberships/1
  # GET /memberships/1.json
  def show

  end

  # GET /memberships/new
  def new
    @membership = @member.memberships.build
    @start_date = Date.current

    @coupons = Stripe::Coupon.list(limit: 50)
  end

  # GET /memberships/1/edit
  def edit
    @coupons = Stripe::Coupon.list(limit: 50)
  end

  # POST /memberships
  # POST /memberships.json
  def create
    ActiveRecord::Base.transaction do
      @membership = @member.memberships.build(membership_params)
      @plan = Plan.find(params[:membership][:plan_id])
      coupon = params[:membership][:coupon].present? ? params[:membership][:coupon] : nil
      @trial_period_end = params[:membership][:trial_period_days].present? ? set_trial_period_end_date : 'now'

      if params[:membership][:payment_type] == 'Stripe'
        stripe_sub = Stripe::Subscription.create(
          customer: @member.stripe_id,
          trial_end: @trial_period_end,
          coupon: coupon,
          :items => [
            {
              :plan => @plan.stripe_id,
            },
          ]
        )

        @membership.next_invoice_date = Time.at(stripe_sub.current_period_end).to_datetime
        @membership.start_date = set_start_date
      elsif @plan.stripe_id.present?
        @stripe_plan = Stripe::Plan.retrieve(@plan.stripe_id)
        start_date = set_start_date
        plan_interval = @stripe_plan.interval
        plan_interval_count = @stripe_plan.interval_count
        next_date = case plan_interval
                    when 'day'
                      start_date + plan_interval_count.days
                    when 'week'
                      start_date + plan_interval_count.weeks
                    when 'month'
                      start_date + plan_interval_count.months
                    when 'year'
                      start_date + plan_interval_count.years
                    end
        @membership.next_invoice_date = next_date
      end

      respond_to do |format|
        if @membership.save!
          format.html { redirect_to @member, notice: 'Membership was successfully created.' }
          format.json { render :show, status: :created, location: @membership }
        else
          format.html { render :new }
          format.json { render json: @membership.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /memberships/1
  # PATCH/PUT /memberships/1.json
  def update
    respond_to do |format|
      if @membership.update(membership_params)
        format.html { redirect_to @member, notice: 'Membership was successfully updated.' }
        format.json { render :show, status: :ok, location: @membership }
      else
        format.html { render :edit }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.json
  def destroy
    ActiveRecord::Base.transaction do
      if @membership.payment_type == 'Stripe'
        stripe_customer = Stripe::Customer.retrieve(@member.stripe_id)
        stripe_customer.subscriptions.each do |sub|
          sub.delete if sub.plan.id == @membership.plan.stripe_id
        end
      end

      @membership.destroy

      respond_to do |format|
        format.html { redirect_to @member, notice: 'Membership was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /memberships/1/cancel
  def cancel
    ActiveRecord::Base.transaction do
      if @membership.payment_type == 'Stripe'
        stripe_customer = Stripe::Customer.retrieve(@member.stripe_id)
        stripe_customer.subscriptions.each do |sub|
          sub.delete(at_period_end: true) if sub.plan.id == @membership.plan.stripe_id
          @end_date = sub.current_period_end
        end

        @membership.end_date = Time.at(@end_date).to_date
        @membership.next_invoice_date = nil
        @membership.save!
      end

      respond_to do |format|
        format.html { redirect_to @member, notice: 'Membership was successfully canceled.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    def set_member
      @member = Member.find(params[:member_id])
    end

    def set_trial_period_end_date
      (params[:membership][:trial_period_days].to_datetime + 12.hours).to_i
    end

    def set_start_date
      if @trial_period_end == 'now'
        return params[:membership][:start_date] || Date.current
      else
        return Time.at(@trial_period_end)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def membership_params
      params.require(:membership).permit(:type, :start_date, :end_date, :membership_type, :payment_type, :notes,
      :plan_id, :plan_category_id, :paid_by, :average_monthly_payment, :trial_period_days, member_attributes: [:id, :first_name, :last_name])
    end
end
