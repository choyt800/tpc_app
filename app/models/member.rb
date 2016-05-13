class Member < ActiveRecord::Base
    
    belongs_to :keycard
    accepts_nested_attributes_for :keycard, allow_destroy: true
    
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :membership_type, presence: true
    validates :mailbox_number, :allow_blank => true, length: { is: 3,  message: " should be 3 digits" }
    
  
    def days_as_member
      if start_date != nil 
       @days = (Date.today.to_date - start_date.to_date).to_i
      end
    end
    
    
   
    
end
