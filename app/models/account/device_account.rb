unless defined? DeviceAccount
  class DeviceAccount < Account
    include RailsCom::Account::DeviceAccount
  end
end
