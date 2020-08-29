module RailsCom::Account::ThirdpartyAccount
  extend ActiveSupport::Concern

  included do
    attribute :confirmed, :boolean, default: true
    validates :identity, uniqueness: { scope: :source }
  end

  def can_login?(params = {})
    join(params) if user.nil?

    user
  end
end
