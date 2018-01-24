class PlanCategory < ActiveRecord::Base
  has_many :plans

  scope :memberships, -> { where('name IN (?)', ['Resident Access', 'Community Access', 'Private Office']) }
  scope :mail_service, -> { where(name: 'Mail Service') }
  scope :misc, -> { where(name: 'Misc') }
  scope :uncategorized, -> { Plan.all.where(plan_category_id: nil) }
end
