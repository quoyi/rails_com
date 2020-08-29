module RailsCom::Account::MobileAccount
  extend ActiveSupport::Concern

  included do
    has_many :check_tokens, class_name: 'MobileToken', foreign_key: :account_id, dependent: :delete_all
  end

  def reset_notice
    puts 'sends sms here'
  end

  def reset_token
    authorized_token.token = rand(10_000..999_999)
    authorized_token.expire_at = 1.hour.since
    authorized_token.save
    authorized_token.token
  end
end
