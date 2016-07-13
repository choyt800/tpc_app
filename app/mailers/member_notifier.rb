class MemberNotifier < ApplicationMailer
    default :from => 'team@thepioneercollective.com'

    # send a signup email to the user, pass in the user object that   contains the user's email address
    def send_welcome_email(member)
        @member = member
        mail( :to => @member.email,
        :subject => 'Welcome to the Pioneer Collective!' )
    end
end
