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

  private

  def modify_plan(name, category, index)
    if plan = Plan.find_by(name: name)
      plan.update_attributes(category: category, category_order: index)
      print '.'
    else
      print '!'
    end
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
