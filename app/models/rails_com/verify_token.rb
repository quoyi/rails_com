# Deal with token
#
# 用于处理Token
module RailsCom::VerifyToken
  extend ActiveSupport::Concern

  included do
    attribute :type, :string
    attribute :token, :string
    attribute :expire_at, :datetime
    attribute :identity, :string
    attribute :access_counter, :integer, default: 0
    belongs_to :account
    belongs_to :user, optional: true

    scope :valid, -> { where('expire_at >= ?', Time.now).order(expire_at: :desc) }
    validates :token, presence: true
    after_initialize :update_token, if: -> { new_record? }
  end

  def update_token
    if account
      self.user_id = account.user_id
      self.identity ||= account.identity
    end

    self.token ||= SecureRandom.uuid
    self.expire_at ||= 14.days.since
    self
  end

  def update_token!
    update_token
    save
    self
  end

  def verify_token?(now = Time.now)
    return false if self.expire_at.blank?

    if now > self.expire_at
      errors.add(:token, 'The token has expired')
      return false
    end

    true
  end

  def send_out
    raise 'should implement in subclass'
  end

  class_methods do
    def create_with_account(identity)
      verify_token = valid.find_by(identity: identity)
      return verify_token if verify_token

      verify_token = new(identity: identity)
      transaction do
        where(identity: identity).delete_all
        verify_token.save!
      end
      verify_token
    end
  end
end
