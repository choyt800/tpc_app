class Member < ActiveRecord::Base
  before_destroy :check

  require 'date'
  require 'time'

  has_attached_file :avatar, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: "missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  has_attached_file :document
  validates_attachment :document, :content_type => { :content_type => %w(application/pdf) }

  has_many :checkins, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :custom_subscriptions, dependent: :destroy
  has_many :keycard_checkouts, dependent: :destroy
  has_many :mail_services, dependent: :destroy
  belongs_to :team

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  def self.active
    Member
      .joins('INNER JOIN "memberships" ON "memberships"."member_id" = "members"."id"')
      .joins('LEFT OUTER JOIN "custom_subscriptions" ON "custom_subscriptions"."member_id" = "members"."id"')
      .distinct
      .where("memberships.end_date IS NULL OR custom_subscriptions.end_date IS NULL")
  end

  def self.inactive
    Member.where.not(id: Member.active.select('id'))
  end

  def self.unassigned
    includes(:memberships).where("memberships.id": nil)
  end

  def full_name
    "#{last_name}, #{first_name}"
  end

  def days_as_member
    if start_date != nil
      @days = (Date.today.to_date - start_date.to_date).to_i
    end
  end

  def current_membership_start_date
    if last_change_date?
      start_date = last_change_date
    else
      start_date = start_date
    end
  end

  def self.dummy_stripe_id
    # If a customer doesn't have a Stripe Customer ID, we'll use this one instead.
    # It's the ID of `david@plateau.digital`, which doesn't have a card attached.

    if Rails.env.production?
      'cus_D1zJVzPK2ek7JG'
    else
      'cus_D1zMSJ2nym2tZo'
    end
  end
end
