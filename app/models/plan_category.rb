class PlanCategory < ActiveRecord::Base
  has_many :plans

  scope :memberships, -> { where('name IN (?)', ['Resident Access', 'Community Access', 'Private Office']) }
  scope :mail_service, -> { where(name: 'Mail Service') }
  scope :memberships_and_mail_service, -> { where('name IN (?)', ['Resident Access', 'Community Access', 'Private Office', 'Mail Service']) }
  scope :misc, -> { where(name: 'Misc') }
  scope :uncategorized, -> { Plan.all.where(plan_category_id: nil) }
end
