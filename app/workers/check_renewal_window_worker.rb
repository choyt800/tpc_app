class CheckRenewalWindowWorker
  include Sidekiq::Worker

  def perform(*args)
    CustomSubscription.all.each do |cs|
      if cs.stripe_sub_id.present?
        days_away = (cs.next_invoice_date.to_date - Date.tomorrow.to_date).to_i

        # if days_away == 45
        if days_away == -13
          stripe_sub = Stripe::Subscription.retrieve(cs.stripe_sub_id)
          interval = "#{stripe_sub.items.data.first.plan.interval_count} #{stripe_sub.items.data.first.plan.interval}"

          # if interval == '6 month'
          SendRenewalEmailWorker.perform_async(cs.id) if interval == '1 month'
        end
      end
    end
  end
end

Sidekiq::Cron::Job.create(name: 'Check Renewal Window Worker - every day', cron: '0 6 * * *', class: 'CheckRenewalWindowWorker')
