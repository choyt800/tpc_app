class Team < ActiveRecord::Base
  has_many :members
  has_many :memberships, dependent: :destroy
  has_many :custom_subscriptions, dependent: :destroy
  has_many :keycard_checkouts, dependent: :destroy
  has_many :mail_services, dependent: :destroy

  has_attached_file :avatar, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  has_attached_file :document
  validates_attachment :document, :content_type => { :content_type => %w(application/pdf) }

  def self.active
    joins(:custom_subscriptions).distinct.where('custom_subscriptions.end_date IS NULL')
  end

  def self.inactive
    joins(:custom_subscriptions).distinct.where('custom_subscriptions.end_date IS NOT NULL')
  end

  def self.unassigned
    includes(:custom_subscriptions).where('custom_subscriptions.id': nil)
  end

  def contact_email
    billing_email || member_email
  end
end
