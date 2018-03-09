require 'stripe'

namespace :stripe_plans do
  desc 'Download a list of all current plans on the source Stripe account'
  task download: :environment do
    puts "----------"
    puts 'Downloading the plans from the source Stripe account'

    use_stripe_key('source')

    stripe_plans = Stripe::Plan.list
    @plans = []

    stripe_plans.auto_paging_each do |sp|
      plan = {
        id: sp[:id],
        amount: sp[:amount],
        currency: sp[:currency],
        interval: sp[:interval],
        interval_count: sp[:interval_count],
        # metadata: sp[:metadata],
        name: sp[:name],
        statement_descriptor: sp[:statement_descriptor],
        trial_period_days: sp[:trial_period_days]
      }

      @plans.push(plan)
      print '.'
    end

    puts "\nSaved #{@plans.count} plans."
  end

  desc 'Print out the list of all current plans on the source Stripe account'
  task list: :download do
    puts @plans.inspect
  end

  desc 'Upload the list of all current plans to the destination Stripe account'
  task upload: :download do
    puts "\n----------"
    puts 'Creating the plans on the destination Stripe account (if they don\'t exist)'

    use_stripe_key('destination')
    existing_plans = []
    creating_plans = []

    @plans.each do |plan|
      begin
        Stripe::Plan.retrieve(plan[:id])
        existing_plans.push(plan[:id])
        print '!'
      rescue Stripe::StripeError
        create_stripe_plan(plan)
        creating_plans.push(plan[:id])
        print '.'
      end
    end

    puts "\n-----"
    puts "Created #{creating_plans.count} plans - #{creating_plans.inspect}"
    puts "Did not create #{existing_plans.count} plans - #{existing_plans.inspect}"
    puts "----------"
  end

  desc 'Sync the list of all current plans to the local database'
  task sync_db: :download do
    puts "\n----------"
    puts 'Creating the plans in the local DB (if they don\'t exist)'

    Plan.skip_callback(:create, :before, :create_stripe_plan)

    count = 0
    @plans.each do |plan|
      if Plan.find_by(stripe_id: plan[:id])
        print '.'
      else
        create_database_plan(plan)
        count += 1
        print '+'
      end
    end

    Plan.set_callback(:create, :before, :create_stripe_plan)

    puts "\nCreated #{count} out of #{@plans.count} plans. There are now #{Plan.count} plans in the database."
  end

  desc 'Update all current local database plans with up-to-date info from Stripe'
  task update_db: :download do
    @plans.each do |plan|
      if db_plan = Plan.find_by(stripe_id: plan[:id])
        update_database_plan(db_plan, plan)
        print '+'
      else
        print '!'
      end
    end
  end
  private

  def prompt_for_key(direction)
    print "What is the Stripe Secret Key for the __#{direction}__  account? - "
    return STDIN.gets.chomp
  end

  def use_stripe_key(direction)
    Stripe.api_key = (direction == 'source' ? prompt_for_key('source') : prompt_for_key('destination'))
  end

  def create_stripe_plan(plan)
    Stripe::Plan.create(
      id: plan[:id],
      amount: plan[:amount],
      currency: plan[:currency],
      interval: plan[:interval],
      interval_count: plan[:interval_count],
      # metadata: plan[:metadata],
      name: plan[:name],
      statement_descriptor: plan[:statement_descriptor],
      trial_period_days: plan[:trial_period_days]
    )
  end

  def create_database_plan(plan)
    Plan.create!(
      stripe_id: plan[:id],
      name: plan[:name],
      interval: plan[:interval],
      interval_count: plan[:interval_count],
      amount: plan[:amount],
      trial_period_days: plan[:trial_period_days]
    )
  end

  def update_database_plan(db_plan, stripe_plan)
    db_plan.update_attributes!(
      stripe_id: stripe_plan[:id],
      name: stripe_plan[:name],
      interval: stripe_plan[:interval],
      interval_count: stripe_plan[:interval_count],
      amount: stripe_plan[:amount],
      trial_period_days: stripe_plan[:trial_period_days]
    )
  end
end
