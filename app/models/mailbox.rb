class Mailbox < ActiveRecord::Base
    has_many :mail_services
end
