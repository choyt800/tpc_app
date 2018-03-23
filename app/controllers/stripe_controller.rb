class StripeController < ApplicationController
  skip_before_action :authenticate_admin!
  protect_from_forgery except: :webhook

  def webhook
    event_type = params[:type]

    if event_type == "invoice.payment_succeeded"
      event_data = params[:data][:object]
      event_subscription = event_data[:subscription]
      event_period_end = event_data[:period_end]
      event_amount_due = event_data[:amount_due]

      membership = Membership.find_by(stripe_sub_id: event_subscription)
      mail_service = MailService.find_by(stripe_sub_id: event_subscription)

      if membership
        membership.update_attributes!(next_invoice_date: Time.at(event_period_end), invoice_amount: event_amount_due)
        puts "Updated membership #{membership.id} with Next Invoice Date of #{Time.at(event_period_end)} and Invoice Amount of #{event_amount_due}"
      elsif mail_service
        mail_service.update_attributes!(next_invoice_date: Time.at(event_period_end), invoice_amount: event_amount_due)
        puts "Updated mail service #{mail_service.id} with Next Invoice Date of #{Time.at(event_period_end)} and Invoice Amount of #{event_amount_due}"
      else
        puts "No membership or mail service found with Stripe Sub ID #{event_subscription}"
      end
    end

    render nothing: true, status: 200
  end
end
