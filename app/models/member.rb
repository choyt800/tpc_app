class Member < ActiveRecord::Base
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
  
  def self.active_all
    active.merge(active_team_members)
  end
  #shows all active members (stripe and non stripe), all active team_members and unassigned members

  def self.active
    joins(:custom_subscriptions).distinct.where("custom_subscriptions.end_date": nil)
  end

 

  def self.active_stripe
    Member.active
      .where('custom_subscriptions.stripe_sub_id IS NOT NULL')
  end

  def self.active_non_stripe
    Member.active
      .where('custom_subscriptions.stripe_sub_id IS NULL')
  end

  def self.inactive
    # joins(:custom_subscriptions).distinct.where.not("custom_subscriptions.end_date": nil)
    joins(:custom_subscriptions).distinct.where.not(id: Member.active.select('member_id'))
  end

  def self.unassigned
    includes(:custom_subscriptions).where("custom_subscriptions.id": nil).where('members.team_id IS NULL')
  end

  def self.team_members
    Member.where('team_id IS NOT NULL')
  end

  def self.active_team_members
    Member.team_members.where(team_active: true)
  end

  def self.inactive_team_members
    Member.team_members.where(team_active: false)
  end

  def unassigned_team_members
    Team.unassigned
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
