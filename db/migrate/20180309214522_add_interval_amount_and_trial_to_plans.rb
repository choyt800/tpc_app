class AddIntervalAmountAndTrialToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :interval, :string, default: 'month'
    add_column :plans, :interval_count, :integer
    add_column :plans, :amount, :integer
    add_column :plans, :trial_period_days, :integer
  end
end
