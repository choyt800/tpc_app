class MailServicesController < ApplicationController
  before_action :set_member_or_team, except: [:index]
  before_action :set_mail_service, only: [:show, :edit, :update, :destroy, :cancel]

  # GET /mail_services
  # GET /mail_services.json
  def index
    @mail_services = MailService.all
  end

  # GET /mail_services/1
  # GET /mail_services/1.json
  def show
  end

  # GET /mail_services/new
  def new
    @mail_service = @member.mail_services.build
    @start_date = Date.current
  end

  # GET /mail_services/1/edit
  def edit
  end

  # POST /mail_services
  # POST /mail_services.json
  def create
    ActiveRecord::Base.transaction do
      @mail_service = @member.mail_services.build(mail_service_params)
      @plan = Plan.find(params[:mail_service][:plan_id])
      if params[:mail_service][:payment_type] == 'Stripe'
        stripe_sub = Stripe::Subscription.create(
          customer: @member.stripe_id,
          :items => [
            {
              :plan => @plan.stripe_id,
            },
          ]
        )
        @mail_service.next_invoice_date = Time.at(stripe_sub.current_period_end).to_datetime
      else
        @stripe_plan = Stripe::Plan.retrieve(@plan.stripe_id)
        start_date = params[:mail_service][:start_date] || Date.current
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
        @mail_service.next_invoice_date = next_date
      end

      respond_to do |format|
        if @mail_service.save
          format.html { redirect_to @member, notice: 'Mail service was successfully created.' }
          format.json { render :show, status: :created, location: @mail_service }
        else
          format.html { render :new }
          format.json { render json: @mail_service.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /mail_services/1
  # PATCH/PUT /mail_services/1.json
  def update
    respond_to do |format|
      if @mail_service.update(mail_service_params)
        format.html { redirect_to @member, notice: 'Mail service was successfully updated.' }
        format.json { render :show, status: :ok, location: @mail_service }
      else
        format.html { render :edit }
        format.json { render json: @mail_service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mail_services/1
  # DELETE /mail_services/1.json
  def destroy
    ActiveRecord::Base.transaction do
      if @mail_service.payment_type == 'Stripe'
        stripe_customer = Stripe::Customer.retrieve(@member.stripe_id)
        stripe_customer.subscriptions.each do |sub|
          sub.delete if sub.plan.id == @mail_service.plan.stripe_id
        end
      end

      @mail_service.destroy

      respond_to do |format|
        format.html { redirect_to @member, notice: 'Mail service was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /mail_services/1/cancel
  def cancel
    ActiveRecord::Base.transaction do
      if @mail_service.payment_type == 'Stripe'
        stripe_customer = Stripe::Customer.retrieve(@member.stripe_id)
        stripe_customer.subscriptions.each do |sub|
          sub.delete(at_period_end: true) if sub.plan.id == @mail_service.plan.stripe_id
          @end_date = sub.current_period_end
        end

        @mail_service.end_date = Time.at(@end_date).to_date
      else
        @mail_service.end_date = Date.current
      end

      @mail_service.next_invoice_date = nil
      @mail_service.save!

      respond_to do |format|
        format.html { redirect_to @member, notice: 'Mail service was successfully canceled.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mail_service
      @mail_service = MailService.find(params[:id])
    end

    def set_member_or_team
      @member = params[:member_id] ? Member.find(params[:member_id]) : Team.find(params[:team_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mail_service_params
      params.require(:mail_service).permit(:member_id, :mailbox_id, :start_date, :end_date, :notes, :average_monthly_payment, :payment_type, :plan_id)
    end
end
