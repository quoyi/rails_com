module RailsCom::Account
  extend ActiveSupport::Concern

  included do
    attribute :type, :string, comment: '账号类型'
    attribute :identity, :string, comment: '标识'
    attribute :confirmed, :boolean, default: false, comment: '是否确认'
    attribute :primary, :boolean, default: false, comment: '是否主要'
    attribute :source, :string, comment: '账号来源'

    belongs_to :user, optional: true
    has_many :authorized_tokens, dependent: :delete_all
    has_many :verify_tokens, dependent: :delete_all
    has_many :oauth_users, dependent: :nullify, inverse_of: :account

    scope :without_user, -> { where(user_id: nil) }
    scope :confirmed, -> { where(confirmed: true) }

    validates :identity, presence: true
    validate :validate_identity

    after_initialize if: :new_record? do
      self.type ||= identity.to_s.include?('@') ? 'EmailAccount' : 'MobileAccount'
    end
    after_save :set_primary, if: -> { primary? && saved_change_to_primary? }
    after_update :sync_user, if: -> { saved_change_to_user_id? }
  end

  def set_primary
    return unless user_id

    self.class.base_class.unscoped.where.not(id: id).where(user_id: user_id).update_all(primary: false)
  end

  def sync_user
    oauth_users.update_all(user_id: user_id)
    verify_tokens.update_all(user_id: user_id)
    authorized_tokens.update_all(user_id: user_id)
  end

  # TODO: make better
  def can_login?(params = {})
    errors.clear
    if params[:token].present?
      check_token = verify_tokens.valid.find_by(token: params[:token])

      unless check_token
        errors.add(:base, :wrong_token)
        return false
      end

      self.confirmed = true
      return join(params) if user.nil?

      user.attributes = params.slice(:password, :password_confirmation)
      save
      return user
    elsif params[:password].present?
      unless user.can_login?(params)
        user.errors.details[:base].each { |err| errors.add(:base, err[:error]) }
        return false
      end
    else
      errors.add(:base, :token_blank)
      return false
    end

    if user.nil?
      errors.add(:base, :join_first)
      return false
    end

    user
  end

  def join(params = {})
    if params[:device_id]
      account = ::DeviceAccount.find_by_identity(params[:device_id])
      self.user = account.try(:user)
    end

    user || build_user
    user.assign_attributes params.slice(:name, :password, :password_confirmation, :invited_code)
    self.primary = true
    self.class.transaction do
      user.save!
      save!
    end

    user
  end

  def verify_token
    last_check_token = check_tokens.order(expire_at: :desc).first
    if last_check_token
      last_check_token.verify_token? ? last_check_token : last_check_token.update_token!
    else
      check_tokens.create
    end
  end

  def authorized_token
    last_authorized_token = authorized_tokens.order(expire_at: :desc).first
    if last_authorized_token
      last_authorized_token.verify_token? ? last_authorized_token : last_authorized_token.update_token!
    else
      authorized_tokens.create
    end
  end

  def auth_token
    authorized_token.token
  end

  def reset_token
  end

  def reset_notice
    p 'Should implement in subclass'
  end

  def validate_identity
    errors.add(:identity, :taken) if self.class.where.not(id: id).exists?(confirmed: true, identity: identity)
  end

  class_methods do
    def create_with_identity(identity)
      if identity.to_s.include?('@')
        ::EmailAccount.create(identity: identity)
      else
        ::MobileAccount.create(identity: identity)
      end
    end
  end
end
