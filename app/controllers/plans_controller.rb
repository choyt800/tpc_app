class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy]

  # GET /plans
  # GET /plans.json
  def index
    all_plans = Plan.all.where(deleted: false).where('plan_category_id is not null').order(:plan_category_id)
    uncategorized = Plan.all.where(deleted: false).where('plan_category_id is null')
    @categories = (all_plans + uncategorized).group_by(&:plan_category)
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
  end

  # GET /plans/new
  def new
    @plan = Plan.new
  end

  # GET /plans/1/edit
  def edit
  end

  # POST /plans
  # POST /plans.json
  def create
    @plan = Plan.new(plan_create_params)
    @plan.assign_params_from_controller(plan_create_params)

    respond_to do |format|
      if @plan.save
        format.html { redirect_to @plan, notice: 'Plan was successfully created.' }
        format.json { render :show, status: :created, location: @plan }
      else
        format.html { redirect_to @plan, notice: 'ERROR - Stripe ID probably already exists' }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    respond_to do |format|
      if @plan.update(plan_edit_params)
        format.html { redirect_to @plan, notice: 'Plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @plan }
      else
        format.html { render :edit }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def change_order
    @plan_category = PlanCategory.find_by(name: params[:category])
    @plans = @plan_category.plans
    sorted_ids = params[:sortedIDs]
    successful = true

    sorted_ids.each_with_index do |id, index|
      plan = Plan.find(id)
      successful = false unless plan.update_attributes(category_order: index + 1)
      puts "#{index + 1} = #{Plan.find(id).name}"
    end

    respond_to do |format|
      if successful
        # format.html { redirect_to @plan, notice: 'Plan was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        # format.html { render :edit }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    if @plan.stripe_id
      plan = Stripe::Plan.retrieve(@plan.stripe_id)
      plan.delete
    end
    @plan.update_attributes(deleted: true)
    respond_to do |format|
      format.html { redirect_to plans_url, notice: 'Plan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plan
      @plan = Plan.find(params[:id])
      @stripe_plan = Stripe::Plan.retrieve(@plan.stripe_id) if @plan.stripe_id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plan_edit_params
      params.require(:plan).permit(:name, :category, :category_order)
    end

    def plan_create_params
      params.require(:plan).permit(:name, :amount, :dollar_amount, :interval, :interval_count,
                                   :trial_period_days, :plan_category_id, :category_order)
    end
end
