class MailService < ActiveRecord::Base
    belongs_to :member
    belongs_to :mailbox
end
