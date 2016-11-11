class Checkin < ActiveRecord::Base
    
    require 'date'
    require 'time'
    
    belongs_to :member
    
    validates :member_id, presence: true
    validates :date, presence: true
  
    
 
    
end
