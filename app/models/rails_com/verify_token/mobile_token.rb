module RailsCom::VerifyToken::MobileToken
  extend ActiveSupport::Concern

  included do
    validates :identity, presence: true
  end

  def update_token
    self.token = rand(10_000..999_999)
    self.expire_at = 10.minutes.since
    super
    self
  end

  def send_out
    puts "sends sms here #{token}"
    true
  end
end
