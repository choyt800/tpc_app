class CheckinsController < ApplicationController
    def new
        @members = Member.all.order('lower(last_name) ASC')
        @checkin = Checkin.new
    end
    
    def create
     
       @checkin = Checkin.new(checkin_params)
       
       if @checkin.save
           flash[:success]="Yay you checked in"
           redirect_to checkins_path
           
       else
           flash[:error]=":-) epic fail"
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
