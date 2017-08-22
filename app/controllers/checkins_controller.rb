class CheckinsController < ApplicationController
    skip_before_action :authenticate_admin!, only: [:new, :create, :index, :set_checkin, :checkin_params]
    def new
        @members = Member.all
        @checkin = Checkin.new
        @checkins = Checkin.all
        render :layout => "member_facing"
    end
    
    def create
     
       @checkin = Checkin.new(checkin_params)
       
       if @checkin.save
           flash[:success]="Yay you checked in"
           redirect_to new_checkin_path
           
       else
           flash[:error]=":-) uh oh"
           render new
       end
    end
    
    def index
        @checkins = Checkin.all.order('created_at DESC')
    end
    
    private
    # Use callbacks to share common setup or constraints between actions.
    def set_checkin
      @checkin = Checkin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
   
    
    def checkin_params
        params.require(:checkin).permit(:date, :member_id)
    end
    
    
   
    
end
