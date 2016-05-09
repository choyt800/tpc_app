class Member < ActiveRecord::Base
    
    belongs_to :keycard
    accepts_nested_attributes_for :keycard, allow_destroy: true
    
  
    def days_as_member
      if start_date != nil 
       @days = (Date.today.to_date - start_date.to_date).to_i
      end
    end
    
   
    
end
