class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update, :destroy]
  require 'date'

  # GET /members
  # GET /members.json
  def index
    @members = Member.all.order('lower(last_name) ASC')
  
  end
  
  def inactive
    @members = Member.all.order('lower(last_name) ASC')
  end

  # GET /members/1
  # GET /members/1.json
  def show
    @member = Member.find(params[:id])
    @members = Member.all.order('lower(last_name) ASC')
  end

  # GET /members/new
  def new
    @member = Member.new
    @keycard = @member.build_keycard
    
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
  
        format.html { redirect_to members_path, notice: 'Member was successfully created.' }
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


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:first_name, :last_name, :email, :role, :status, 
       :has_mail_service, :mailbox_number, :phone, :company, :notes, :avatar)
    end
end

