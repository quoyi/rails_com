module RailsCom::OauthUser
  extend ActiveSupport::Concern

  included do
    # t.index [:uid, :provider], unique: true
    attribute :type, :string
    attribute :provider, :string
    attribute :uid, :string
    attribute :unionid, :string, index: true
    attribute :app_id, :string
    attribute :name, :string
    attribute :avatar_url, :string
    attribute :state, :string
    attribute :access_token, :string
    attribute :expires_at, :datetime
    attribute :refresh_token, :string
    attribute :extra, :json, default: {}

    belongs_to :account, optional: true, inverse_of: :oauth_users

    belongs_to :user, autosave: true, optional: true

    has_one :same_oauth_user,
            ->(o) { where.not(id: o.id, unionid: nil, user_id: nil) },
            class_name: name, foreign_key: :unionid, primary_key: :unionid

    has_many :same_oauth_users,
             ->(o) { where.not(id: o.id).where.not(unionid: nil) },
             class_name: name, foreign_key: :unionid, primary_key: :unionid

    has_many :authorized_tokens, dependent: :delete_all

    validates :provider, presence: true
    validates :uid, presence: true

    before_validation do
      # TODO: better user sync logic
      self.user_id = account&.user_id if account_id_changed?
    end
  end

  def save_info(info_params)
  end

  def strategy
  end

  def generate_auth_token(**options)
    JwtHelper.generate_jwt_token(id, password_digest, options)
  end

  def get_authorized_token(session_key = nil)
    authorized_token = authorized_tokens.order(expire_at: :desc).first
    if authorized_token
      if authorized_token.verify_token?
        authorized_token
      else
        authorized_token.session_key ||= session_key
        authorized_token.update_token!
      end
    else
      authorized_tokens.create(session_key: session_key)
    end
  end

  def auth_token(session_key = nil)
    get_authorized_token(session_key).token
  end

  def refresh_token!
    client = strategy
    token = OAuth2::AccessToken.new client, access_token, { expires_at: expires_at.to_i, refresh_token: refresh_token }
    token.refresh!
  end
end
