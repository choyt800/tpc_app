class KeycardCheckout < ActiveRecord::Base
    belongs_to :member
    belongs_to :keycard
    
    validates :member_id, presence: true
    validates :start_date, presence: true
    
    accepts_nested_attributes_for :keycard
    
    def status
        if end_date? 
            "cancelled"
        else
            "live"
        end
    end
end
 
 
