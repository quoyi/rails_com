##
# include this module to your User model
#   class User < ApplicationRecord
#     include RailsCom::User
#   end
module RailsCom::User
  extend ActiveSupport::Concern

  included do
    include ActiveModel::SecurePassword
    has_secure_password validations: false

    attribute :name, :string
    attribute :password_digest, :string
    attribute :locale, :string, default: I18n.default_locale
    attribute :timezone, :string
    attribute :last_login_at, :datetime
    attribute :last_login_ip, :string
    attribute :disabled, :boolean, default: false
    attribute :source, :string
    attribute :invited_code, :string

    has_many :authorized_tokens, dependent: :delete_all
    has_many :verify_tokens, autosave: true, dependent: :delete_all
    has_many :oauth_users, dependent: :nullify
    has_many :accounts, inverse_of: :user, dependent: :nullify
    has_many :confirmed_accounts, -> { where(confirmed: true) }, class_name: 'Account'
    accepts_nested_attributes_for :accounts

    has_many :user_taggeds, dependent: :destroy
    has_many :user_tags, through: :user_taggeds

    has_one_attached :avatar

    validates :password, confirmation: true, length: { in: 6..72 }, allow_blank: true

    before_save :invalid_authorized_token, if: -> { password_digest_changed? }
  end

  def auth_tokens
    authorized_tokens.pluck(:token)
  end

  def primary_account
    accounts.find_by(primary: true)
  end

  def join(params = {})
    assign_attributes(params.slice(:name,
                                   :email,
                                   :mobile,
                                   :password,
                                   :password_confirmation))
    save
  end

  # pass login params to this method;
  def can_login?(params)
    if password_digest.blank?
      errors.add :base, :password_reject
      return false
    end

    unless authenticate(params[:password])
      errors.add :base, :wrong_name_or_password
      return false
    end

    if disabled?
      errors.add :base, :account_disable
      return false
    end

    self
  end

  def avatar_url
    return avatar.url if avatar.attached?

    url = oauth_users.first&.avatar_url.presence
    return url if url

    avatar.url if avatar.present?
  end

  def valid_providers
    ::OauthUser.options_i18n(:provider).values.map(&:to_s) - oauth_providers
  end

  def invalid_authorized_token
    authorized_tokens.delete_all
  end

  def account_identities
    confirmed_accounts.map(&:identity)
  end

  def oauth_providers
    oauth_users.pluck(:provider).compact
  end
end
