class Team < ActiveRecord::Base
  has_many :members
  has_many :memberships, dependent: :destroy
  has_many :keycard_checkouts, dependent: :destroy
  has_many :mail_services, dependent: :destroy

  has_attached_file :avatar, styles: { medium: "300x300#", thumb: "100x100#" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  has_attached_file :document
  validates_attachment :document, :content_type => { :content_type => %w(application/pdf) }

  def contact_email
    billing_email || member_email
  end
end
