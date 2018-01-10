class KeycardCheckoutsController < ApplicationController
  before_action :set_member_or_team, except: [:index]
  before_action :set_keycard_checkouts, only: [:show, :edit, :update, :destroy, :cancel]

  # GET /keycard_checkouts
  # GET /keycard_checkouts.json
  def index
    @keycard_checkouts = KeycardCheckout.joins(:keycard).order("number")
  end

  # GET /keycard_checkouts/1
  # GET /keycard_checkouts/1.json
  def show

  end

  # GET /keycard_checkouts/new
  def new
    @keycard_checkout = @member.keycard_checkouts.build
    @keycard_checkout.build_keycard
    @start_date = Date.current
  end

  # GET /keycard_checkouts/1/edit
  def edit
  end

  # POST /keycard_checkouts
  # POST /keycard_checkouts.json
  def create
    ActiveRecord::Base.transaction do
      @keycard_checkout = @member.keycard_checkouts.build(keycard_checkout_params)

      existing_keycard = Keycard.find_by(number: @keycard_checkout.keycard.number)

      if existing_keycard
        @keycard_checkout.keycard = existing_keycard
      end

      charge_deposit if params[:keycard_checkout][:payment_type] == 'Stripe' && params[:keycard_checkout][:deposit] == '1'

      respond_to do |format|
        if @keycard_checkout.save
          format.html { redirect_to @member, notice: 'keycard_checkout record was successfully created.' }
          format.json { render :show, status: :created, location: @keycard_checkout }
        else
          format.html { render :new }
          format.json { render json: @keycard_checkout.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /keycard_checkouts/1
  # PATCH/PUT /keycard_checkouts/1.json
  def update
    respond_to do |format|
      charge_deposit if @keycard_checkout.payment_type == 'Stripe' && params[:keycard_checkout][:deposit] == '1'
      refund_deposit if @keycard_checkout.payment_type == 'Stripe' && params[:keycard_checkout][:refund] == '1'

      if @keycard_checkout.update(keycard_checkout_params)
        format.html { redirect_to @member, notice: 'keycard_checkouts record was successfully updated.' }
        format.json { render :show, status: :ok, location: @keycard_checkouts }
      else
        format.html { render :edit }
        format.json { render json: @keycard_checkout.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keycard_checkouts/1
  # DELETE /keycard_checkouts/1.json
  def destroy
    ActiveRecord::Base.transaction do
      @keycard_checkout.destroy

      respond_to do |format|
        format.html { redirect_to @member, notice: 'keycard_checkout was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /keycard_checkouts/1/cancel
  def cancel
    refund_deposit if @keycard_checkout.payment_type == 'Stripe'
    @keycard_checkout.update_attributes!(end_date: Date.current)

    ActiveRecord::Base.transaction do
      respond_to do |format|
        format.html { redirect_to @member, notice: 'Keycard checkout was successfully canceled.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keycard_checkouts
      @keycard_checkout = KeycardCheckout.find(params[:id])
    end

    def set_member_or_team
      @member = params[:member_id] ? Member.find(params[:member_id]) : Team.find(params[:team_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keycard_checkout_params
      params.require(:keycard_checkout).permit(:start_date, :end_date, :keycard_id, :plan_id, :payment_type, member_attributes: [:id, :first_name, :last_name], keycard_attributes: [:number, :hours])
    end

    def charge_deposit
      # Create and charge deposit
      stripe_deposit = Stripe::Charge.create(
        :amount => 5000,
        :currency => "usd",
        :customer => @member.stripe_id,
        :description => "Keycard Checkout Security Deposit"
      )
      @keycard_checkout.stripe_charge_id = stripe_deposit.id if stripe_deposit
    end

    def refund_deposit
      puts '!!!!!'
      puts 'In refund...'
      unless @keycard_checkout.stripe_charge_refunded
        puts 'No existing refunds...'
        re = Stripe::Refund.create(
          charge: @keycard_checkout.stripe_charge_id,
          amount: 2500
        )
        puts "Refund created - #{re.inspect}"
      end

      @keycard_checkout.update_attributes(stripe_charge_refunded: true)
      puts '!!!!!'
    end

end
