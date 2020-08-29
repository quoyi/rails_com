module RailsCom::Account::DeviceAccount
  def can_login?(params = {})
    join(params) if user.nil?

    user
  end
end
