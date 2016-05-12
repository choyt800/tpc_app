class KeycardsController < ApplicationController
  before_action :set_keycard, only: [:show, :edit, :update, :destroy]
  
  # GET /keycards
  # GET /keycards.json
  def index
    @keycards = keycard.all
  end

  # GET /keycards/1
  # GET /keycards/1.json
  def show
  end

  # GET /keycards/new
  def new
    @keycard = keycard.new
  end

  # GET /keycards/1/edit
  def edit
  end

  # POST /keycards
  # POST /keycards.json
  def create
    @keycard = keycard.new(keycard_params)

    respond_to do |format|
      if @keycard.save
        format.html { redirect_to @keycard, notice: 'keycard was successfully created.' }
        format.json { render :show, status: :created, location: @keycard }
      else
        format.html { render :new }
        format.json { render json: @keycard.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keycards/1
  # PATCH/PUT /keycards/1.json
  def update
    respond_to do |format|
      if @keycard.update(keycard_params)
        format.html { redirect_to @keycard, notice: 'keycard was successfully updated.' }
        format.json { render :show, status: :ok, location: @keycard }
      else
        format.html { render :edit }
        format.json { render json: @keycard.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keycards/1
  # DELETE /keycards/1.json
  def destroy
    @keycard.destroy
    respond_to do |format|
      format.html { redirect_to keycards_url, notice: 'keycard was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keycard
      @keycard = keycard.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def keycard_params
      params.require(:keycard).permit( :number, :hours)
    end
end
