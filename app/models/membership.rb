class Membership < ActiveRecord::Base
    
    belongs_to :member
    belongs_to :plan
    
     def next_bill_date
        if start_date?
            #calculate next bill date if member is on month-to-month membership
            if payment_type == "Month-to-month"
                
                if Date.today.strftime("%d").to_i < start_date.strftime("%d").to_i 
          
                    @next_bill = "#{Date.today.year}-#{Date.today.strftime("%m")}-#{start_date.strftime("%d")}"
                
                else
                     if Date.today.month.to_i != 12    
                        @next_bill = "#{Date.today.year}-#{1.month.from_now.month}-#{start_date.strftime("%d")}" 
                     else
                         @next_bill = "#{1.year.from_now.year}-#{1.month.from_now.month}-#{start_date.strftime("%d")}"
                     end
              
                end
                
               
            #calculate next bill date if member is on prepaid membership   
            elsif payment_type.include? "Prepaid"
                
                x = payment_type.gsub(/[^\d]/, '').to_i
            
                if Date.today < (start_date.to_date + x.months)
                    @next_bill =  start_date.to_date + x.months
                else
                    y = ((Date.today - start_date.to_date).to_i) / (x * 30)
                    @next_bill = (start_date.to_date + x.months + ((y * x).months))
                end
                
                
            else
                
                @next_bill =  "N/A"    
            end   
            
            @next_bill
        end
    end
    
   
    
    def length_of_membership
        if end_date != nil
            length_of_membership = ((end_date - start_date) / 86400).to_i
        else 
            length_of_membership = (Date.today.mjd - start_date.to_date.mjd).to_i
        end
        
    end
    
    def status
        if end_date? 
            "cancelled"
        else
            "live"
        end
    end
    
    
    
    
    
    
end
