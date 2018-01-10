class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy, :create_stripe, :link_stripe, :update_stripe]
  def index
    @teams = Team.all
  end

  def show
    @stripe_customer = Stripe::Customer.retrieve(@team.stripe_id) if @team.stripe_id
    @stripe_card = @stripe_customer.sources.retrieve(@stripe_customer.default_source) if @stripe_customer
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Team was successfully created.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
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

    @team.stripe_id = customer.id
    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Stripe Customer was successfully created.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def link_stripe
    begin
      @stripe_customer = Stripe::Customer.retrieve(params[:stripe_id])
    rescue Stripe::InvalidRequestError
      respond_to do |format|
        format.html { redirect_to @team, notice: 'ERROR: Stripe Customer not found.' and return }
        format.json { render json: 'Stripe Customer not found', status: :unprocessable_entity and return }
      end
    end

    @team.stripe_id = params[:stripe_id]
    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_stripe
    customer = Stripe::Customer.retrieve(@team.stripe_id)
    customer.source = params[:stripeToken]

    respond_to do |format|
      if customer.save
        format.html { redirect_to @team, notice: 'Stripe Customer was successfully updated.' }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :owner, :owner_email, :notes)
  end
end
