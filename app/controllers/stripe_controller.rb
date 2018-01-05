class StripeController < ApplicationController
  skip_before_action :authenticate_admin!
  protect_from_forgery except: :webhook

  def webhook
    event_type = params[:type]

    if event_type == "invoice.payment_succeeded"
      event_data = params[:data][:object]
      event_customer = event_data[:customer]
      event_plan_id = event_data[:lines][:data][0][:plan][:id]
      event_period_end = event_data[:period_end]

      member = Member.find_by(stripe_id: event_customer)
      plan = Plan.find_by(stripe_id: event_plan_id)

      if member
        if membership = member.memberships.where(plan_id: plan.id).first
          membership.update_attributes!(next_invoice_date: Time.at(event_period_end))
          puts "Updated membership #{membership.id} with Next Invoice Date of #{Time.at(event_period_end)}"
        elsif mail_service = member.mail_services.where(plan_id: plan.id).first
          mail_service.update_attributes!(next_invoice_date: Time.at(event_period_end))
          puts "Updated mail service #{mail_service.id} with Next Invoice Date of #{Time.at(event_period_end)}"
        else
          puts "No membership or mail service found for Stripe Customer #{event_customer} and plan #{event_plan_id}"
        end
      else
        puts "No member found with Stripe ID #{event_customer}"
      end
    end

    render nothing: true, status: 200
  end
end
