class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy, :create_stripe, :link_stripe, :update_stripe, :update_stripe_source]
  require 'date'

  # GET /members
  # GET /members.json
  def index
    @members =  case params[:filter]
                when 'active'
                  Member.active
                when 'active_all'
                  Member.active_all
                when 'active_stripe'
                  Member.active_stripe
                when 'active_non_stripe'
                  Member.active_non_stripe
                when 'active_team_members'
                  Member.active_team_members
                when 'inactive'
                  Member.inactive
                when 'inactive_team_members'
                  Member.inactive_team_members
                when 'unassigned'
                  Member.unassigned
                else
                  Member.all
                end
  end

  def inactive
    @members = Member.all
  end

  def counts
    @members = Member.all
  end

  # GET /members/1
  # GET /members/1.json
  def show
    @member = Member.find(params[:id])
    @stripe_customer = Stripe::Customer.retrieve(@member.stripe_id) if @member.stripe_id
    @stripe_card = @stripe_customer.sources.retrieve(@stripe_customer.default_source) if @stripe_customer
  end

  # GET /members/new
  def new
    @member = Member.new
    @team = Team.find(params[:team_id]) if params[:team_id]
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save

        # # Deliver the signup email
        # MemberNotifier.send_welcome_email(@member).deliver_now

        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        update_stripe(@member) if @member.stripe_id

        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to members_url, notice: 'Member was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def create_stripe
    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :source  => params[:stripeToken],
      :metadata => {
        "First Name" => params[:firstname],
        "Last Name" => params[:lastname]
      }
    )

    @member.stripe_id = customer.id
    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Stripe Customer was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def link_stripe
    begin
      @stripe_customer = Stripe::Customer.retrieve(params[:stripe_id])
    rescue Stripe::InvalidRequestError
      respond_to do |format|
        format.html { redirect_to @member, notice: 'ERROR: Stripe Customer not found.' and return }
        format.json { render json: 'Stripe Customer not found', status: :unprocessable_entity and return }
      end
    end

    @member.stripe_id = params[:stripe_id]
    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_stripe(member)
    customer = Stripe::Customer.retrieve(member.stripe_id)

    customer.email = member.email
    customer.metadata = {
      'First Name' => member.first_name,
      'Last Name' => member.last_name
    }

    customer.save
  end

  def update_stripe_source
    customer = Stripe::Customer.retrieve(@member.stripe_id)
    customer.source = params[:stripeToken]

    respond_to do |format|
      if customer.save
        format.html { redirect_to @member, notice: 'Stripe Customer was successfully updated.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:first_name, :last_name, :email, :role, :status,
       :has_mail_service, :mailbox_number, :phone, :company, :notes, :avatar, :document, :team_id, :team_active)
    end
end
