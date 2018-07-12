class UpdateStripeDataWorker
  include Sidekiq::Worker

  def perform(*args)
    CustomSubscription.all.each do |cs|
      if cs.stripe_sub_id.present?
        begin
          stripe_sub = Stripe::Subscription.retrieve(cs.stripe_sub_id)
          stripe_next_inv = Stripe::Invoice.upcoming(customer: stripe_sub.customer, subscription: stripe_sub.id)

          if cs.invoice_amount != stripe_next_inv.amount_due || cs.next_invoice_date != Time.at(stripe_next_inv.period_start)
            cs.update_attributes!(invoice_amount: stripe_next_inv.amount_due, next_invoice_date: Time.at(stripe_next_inv.period_start))
          end
        rescue Stripe::InvalidRequestError => e
        end
      end
    end
  end
end

Sidekiq::Cron::Job.create(name: 'Update Stripe Data Worker - every week', cron: '0 10 * * 0', class: 'UpdateStripeDataWorker')
