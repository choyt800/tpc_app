class MembershipsController < ApplicationController
  before_action :set_member, except: [:index]
  before_action :set_membership, only: [:show, :edit, :update, :destroy]


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

  end

  # GET /memberships/1/edit
  def edit
  end

  # POST /memberships
  # POST /memberships.json
  def create
    ActiveRecord::Base.transaction do
      @membership = @member.memberships.build(membership_params)
      @plan = Plan.find(params[:membership][:plan_id])

      if params[:membership][:payment_type] == 'Stripe'
        stripe_sub = Stripe::Subscription.create(
          customer: @member.stripe_id,
          :items => [
            {
              :plan => @plan.stripe_id,
            },
          ]
        )
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_membership
      @membership = Membership.find(params[:id])
    end

    def set_member
      @member = Member.find(params[:member_id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def membership_params
      params.require(:membership).permit(:type, :start_date, :end_date, :membership_type, :payment_type, :notes,
      :plan_id, :plan_category_id, :paid_by, :average_monthly_payment, member_attributes: [:id, :first_name, :last_name])
    end
end
