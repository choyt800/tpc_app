require 'stripe'

namespace :stripe_migration do
  task recategorize: :environment do
    Plan.all.each do |plan|
      plan.update_attributes(category: 'Non-Stripe')
      print '.'
    end
  end

  task categorize_db_plans: :environment do
    print 'Designated Desks: '
    designated_desks.each_with_index { |name, i| modify_plan(name, 'Designated Desk', i) }

    print "\nCommunal Memberships: "
    communal_memberships.each_with_index { |name, i| modify_plan(name, 'Communal Membership', i) }

    print "\nTeam Memberships: "
    team_memberships.each_with_index { |name, i| modify_plan(name, 'Team Membership', i) }

    print "\nMail Service: "
    mail_service.each_with_index { |name, i| modify_plan(name, 'Mail Service', i) }

    print "\nMisc: "
    misc.each_with_index { |name, i| modify_plan(name, 'Misc', i) }
  end

  task update_member_stripe_id: :environment do
    Stripe.api_key = ENV['SECRET_KEY']

    customers = Stripe::Customer.all(:limit => 3)
    customers.auto_paging_each do |customer|
      if member = Member.find_by(email: customer.email)
        member.update_attributes(stripe_id: customer.id)
        puts "Updated: #{customer.email} - #{customer.id}"
      else
        puts "Not found: #{customer.email} - #{customer.id}"
      end
    end
  end

  task update_member_next_invoice_date: :environment do
    Stripe.api_key = ENV['SECRET_KEY']

    puts "Updating Memberships..."
    Membership.all.each do |mship|
      puts "Looking at #{mship.id}"
      if mship.payment_type == 'Stripe'
        if mship.end_date.nil?
          stripe_customer_id = mship.member.present? ? mship.member.stripe_id : mship.team.stripe_id
          begin
            stripe_sub = Stripe::Subscription.list(customer: stripe_customer_id, plan: mship.plan.stripe_id)
          rescue Stripe::InvalidRequestError => e
            puts "UH OH - something happened..."
            puts e.message
            next # skip to the next Membership
          end

          next_invoice_date = Time.at(stripe_sub['data'][0]['current_period_end'])

          if mship.next_invoice_date != next_invoice_date
            mship.update_attributes!(next_invoice_date: next_invoice_date)
            puts "Updated #{mship.id} with #{next_invoice_date}"
          else
            puts "Did not need to update #{mship.id} - existing #{mship.next_invoice_date} matches new #{next_invoice_date}"
          end
        else
          puts "Did not need to update #{mship.id} - end date is #{mship.end_date}"
        end
      else
        puts "Did not need to update #{mship.id} - payment type is #{mship.payment_type}"
      end
    end

    puts "Updating Mail Services..."
    MailService.all.each do |ms|
      if ms.payment_type == 'Stripe'
        if ms.end_date.nil?
          begin
            stripe_sub = Stripe::Subscription.list(customer: ms.member.stripe_id, plan: ms.plan.stripe_id)
          rescue Stripe::InvalidRequestError => e
            puts "UH OH - something happened..."
            puts e.message
            next # skip to the next Mail Service
          end

          next_invoice_date = Time.at(stripe_sub['data'][0]['current_period_end'])

          if ms.next_invoice_date != next_invoice_date
            ms.update_attributes!(next_invoice_date: next_invoice_date)
            puts "Updated #{ms.id} with #{next_invoice_date}"
          else
            puts "Did not need to update #{ms.id} - existing #{ms.next_invoice_date} matches new #{next_invoice_date}"
          end
        else
          puts "Did not need to update #{ms.id} - end date is #{ms.end_date}"
        end
      else
        puts "Did not need to update #{ms.id} - payment type is #{ms.payment_type}"
      end
    end
  end

  task create_plan_categories: :environment do
    print 'Creating new Plan Categories'
    categories.each do |cat|
      print '.'
      PlanCategory.create!(name: cat)
    end
  end

  task update_plan_categories: :environment do
    print "\nUpdating the Plan relationships"
    Plan.all.each do |plan|
      if plan.category
        print '.'
        plan.plan_category = PlanCategory.find_by(name: plan.category) if plan.category
        plan.save!
      else
        print '!'
      end
    end
  end

  private

  def modify_plan(name, category, index)
    if plan = Plan.find_by(name: name)
      cat = PlanCategory.find_by(name: category)
      plan.update_attributes(plan_category_id: cat.id, category_order: index)
      print '.'
    else
      print '!'
    end
  end

  def categories
    [
      'Designated Desk',
      'Communal Membership',
      'Team Membership',
      'Mail Service',
      'Misc'
    ]
  end

  def designated_desks
    [
      'Designated Desk 525',
      'Designated Desk 505',
      'Designated Desk 495',
      'Designated Desk 485',
      'Designated Desk 475',
      'Designated Desk 465',
      'PP-3-Team-Designated-Desk-525',
      'PP-6-Team-Designated-Desk-525',
      'PP-12-Team-Designated-Desk-525',
      'PP-3-Team-Designated-Desk-505',
      'PP-6-Team-Designated-Desk-505',
      'PP-12-Team-Designated-Desk-505',
      'PP-3-Team-Designated-Desk-495',
      'PP-6-Team-Designated-Desk-495',
      'PP-12-Team-Designated-Desk-495',
      'PP-3-Team-Designated-Desk-485',
      'PP-6-Team-Designated-Desk-485',
      'PP-12-Team-Designated-Desk-485',
      'PP-3-Team-Designated-Desk-475',
      'PP-6-Team-Designated-Desk-475',
      'PP-12-Team-Designated-Desk-475'
    ]
  end

  def communal_memberships
    [
      'Community Full Time',
      'Community 10',
      'Community 5',
      'Community 2',
      'PP-3-Team-Comm-FT',
      'PP-6-Team-Comm-FT',
      'PP-12-Team-Comm-FT',
      'PP-3-Team-Comm-10',
      'PP-6-Team-Comm-10',
      'PP-12-Team-Comm-10',
      'PP-3-Team-Comm-5',
      'PP-6-Team-Comm-5',
      'PP-12-Team-Comm-5',
      'PP-3-Team-Comm-2',
      'PP-6-Team-Comm-2',
      'PP-12-Team-Comm-2'
    ]
  end

  def team_memberships
    [
      'Team 48',
      'Team 24',
      'Team 12',
      'Team 6',
      'PP-3-Team-48',
      'PP-6-Team-48',
      'PP-12-Team-48',
      'PP-3-Team-24',
      'PP-6-Team-24',
      'PP-12-Team-24',
      'PP-3-Team-12',
      'PP-6-Team-12',
      'PP-12-Team-12',
      'PP-3-Team-6',
      'PP-6-Team-6',
      'PP-12-Team-6'
    ]
  end

  def mail_service
    [
      'Mail Service',
      'Mail Service - NM',
      'PP-3-Mail Service',
      'PP-6-Mail Service',
      'PP-12-Mail Service',
      'PP-3-Mail Service-NM',
      'PP-6-Mail Service-NM',
      'PP-12-Mail Service-NM'
    ]
  end

  def misc
    [
      'Keycard Add-on'
    ]
  end

end
