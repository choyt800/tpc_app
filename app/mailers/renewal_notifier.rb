class RenewalNotifier < ApplicationMailer
  default :from => 'team@thepioneercollective.com'

  def send_renewal_email(custom_subscription, email_address)
    @custom_subscription = custom_subscription
    mail( :to => email_address,
    :subject => 'Your subscription is about to renew' )
  end
end
