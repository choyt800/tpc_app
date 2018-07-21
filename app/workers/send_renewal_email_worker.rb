class SendRenewalEmailWorker
  include Sidekiq::Worker

  def perform(custom_sub_id)
    cs = CustomSubscription.find(custom_sub_id)
    recipient = cs.member_id ? cs.member.email : cs.team.contact_email
    RenewalNotifier.send_renewal_email(cs, recipient).deliver
  end
end
