class KeycardCheckoutsController < ApplicationController
  before_action :set_member, except: [:index]
  before_action :set_keycard_checkouts, only: [:show, :edit, :update, :destroy]

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

      respond_to do |format|
        if @keycard_checkout.save
          @plan = Plan.find(params[:keycard_checkout][:plan_id])
          if params[:keycard_checkout][:payment_type] == 'Stripe'
            stripe_sub = Stripe::Subscription.create(
              customer: @member.stripe_id,
              :items => [
                {
                  :plan => @plan.stripe_id,
                },
              ]
            )
          end

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
      if @keycard_checkout.payment_type == 'Stripe'
        stripe_customer = Stripe::Customer.retrieve(@member.stripe_id)
        stripe_customer.subscriptions.each do |sub|
          sub.delete if sub.plan.id == @keycard_checkout.plan.stripe_id
        end
      end

      @keycard_checkout.destroy

      respond_to do |format|
        format.html { redirect_to @member, notice: 'keycard_checkout was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keycard_checkouts
      @keycard_checkout = KeycardCheckout.find(params[:id])
    end

     def set_member
       @member = Member.find(params[:member_id])
     end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keycard_checkout_params
      params.require(:keycard_checkout).permit(:start_date, :end_date, :keycard_id, :plan_id, :payment_type, member_attributes: [:id, :first_name, :last_name], keycard_attributes: [:number, :hours])
    end


end
