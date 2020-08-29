unless defined? MobileAccount
  class MobileAccount < Account
    include RailsCom::Account::MobileAccount
  end
end
