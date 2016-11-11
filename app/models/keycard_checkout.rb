class KeycardCheckout < ActiveRecord::Base
    belongs_to :member
    belongs_to :keycard
    
    validates :member_id, presence: true
    validates :keycard_id, presence: true
    validates :start_date, presence: true
    
end
 
 
