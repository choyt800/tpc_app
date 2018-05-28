require 'stripe'

namespace :membership_to_custom_subscription_migration do
  task :migrate, [:live_mode] => :environment do |_t, args|
    live_mode = (args[:live_mode] == 'true')
    puts 'Migrating Memberships to Custom Subs...'

    Membership.all.each do |mship|
      puts "\nLooking at #{mship.id}"

      if mship.stripe_sub_id.present?
        if existing_cs = CustomSubscription.find_by(stripe_sub_id: mship.stripe_sub_id)
          puts "Did not migrate #{mship.id} - Custom Sub #{existing_cs.id} already exists with Stripe Sub ID"
          next
        end

        cs = CustomSubscription.new

        cs.stripe_sub_id =      mship.stripe_sub_id
        cs.member_id =          mship.member_id
        cs.team_id =            mship.team_id
        cs.next_invoice_date =  mship.next_invoice_date
        cs.invoice_amount =     mship.invoice_amount
        cs.start_date =         mship.start_date
        cs.end_date =           mship.end_date
        cs.notes =              mship.notes

        if live_mode
          cs.save!
          cs.update_attributes!(created_at: mship.created_at)
        end

        puts "#{'TEST RUN - ' unless live_mode}Migrated Membership #{mship.id} to #{cs.id}\n"
      else
        puts "Did not migrate #{mship.id} - Stripe Sub ID not present"
      end
    end
  end

  task :update_cs_data, [:live_mode] => :environment do |_t, args|
    live_mode = (args[:live_mode] == 'true')
    Stripe.api_key = ENV['SECRET_KEY']

    puts "Updating Memberships..."
    CustomSubscription.all.each do |cs|
      puts "\nLooking at #{cs.id}"

      if cs.stripe_sub_id.present?
        begin
          stripe_sub = Stripe::Subscription.retrieve(cs.stripe_sub_id)
        rescue Stripe::InvalidRequestError => e
          puts "UH OH - something happened..."
          puts e.message
          next
        end

        stripe_customer_id = cs.member.present? ? cs.member.stripe_id : cs.team.stripe_id
        stripe_next_invoice = Stripe::Invoice.upcoming(customer: stripe_customer_id, subscription: cs.stripe_sub_id)
        next_invoice_date = Time.at(stripe_sub['current_period_end'])
        invoice_amount = stripe_next_invoice['amount_due']

        cs.update_attributes!(next_invoice_date: next_invoice_date, invoice_amount: invoice_amount) if live_mode

        puts "#{'TEST MODE - ' unless live_mode}Updated #{cs.id} with #{next_invoice_date} and #{invoice_amount}"
      else
        puts "Did not update #{cs.id} - no Stripe Sub ID\n"
      end
    end
  end

  task :delete_memberships, [:live_mode] => :environment do |_t, args|
    live_mode = (args[:live_mode] == 'true')
    puts 'Removing migrated Memberships...'

    Membership.all.each do |mship|
      puts "\nLooking at #{mship.id}"

      if mship.stripe_sub_id.present?
        if existing_cs = CustomSubscription.find_by(stripe_sub_id: mship.stripe_sub_id)
          print "Custom Sub #{existing_cs.id} exists for this membership. Deleting..."
          mship.delete if live_mode
          puts "#{'TEST MODE - ' unless live_mode}deleted."
        else
          puts "No migrated Custom Subscription exists for this membership. Not deleting."
        end
      else
        puts "Not a Stripe membership. Not deleting."
      end
    end
  end
end
