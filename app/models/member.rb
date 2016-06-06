class Member < ActiveRecord::Base
    
    require 'date'
    require 'time'
    
    has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
    
    
    belongs_to :keycard
    accepts_nested_attributes_for :keycard, allow_destroy: true
    
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :membership_type, presence: true
    validates :start_date, presence: true
    validates :mailbox_number, :allow_blank => true, length: { is: 3,  message: " should be 3 digits" }
    
    
  

  
    def days_as_member
      if start_date != nil 
       @days = (Date.today.to_date - start_date.to_date).to_i
      end
    end
    
    
    def current_membership_start_date 
        if last_change_date != nil
            start_date = last_change_date
        else
            start_date = start_date
        end
    end
    

  
    
    
 
    
    def next_bill_date
        if start_date != nil
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
end
