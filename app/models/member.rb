class Member < ActiveRecord::Base
    
    require 'date'
    require 'time'
    
    has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/images/:style/missing.png"
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
    
    
    has_one :keycard
    
    
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :email, presence: true
    validates :membership_type, presence: true
    validates :start_date, presence: true
    validates :mailbox_number, :allow_blank => true, length: { is: 3,  message: " should be 3 digits" }
    
    def full_name
        "#{last_name}, #{first_name}"
    end
  
    def days_as_member
      if start_date != nil 
       @days = (Date.today.to_date - start_date.to_date).to_i
      end
    end
    
    
    def current_membership_start_date 
        if last_change_date?
            start_date = last_change_date
        else
            start_date = start_date
        end
    end
    
    
   
end
