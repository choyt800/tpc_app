class Task < ActiveRecord::Base
    
    
      scope :today, -> { where(day: 'Time.now.strftime("%A, %m/%d/%Y"') }
    
    
    
end
