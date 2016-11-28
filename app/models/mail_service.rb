class MailService < ActiveRecord::Base
    belongs_to :member
    belongs_to :mailbox
    
    
    def status
        if end_date? 
            "cancelled"
        else
            "live"
        end
    end
    
end
