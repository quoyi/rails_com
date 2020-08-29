unless defined? ThirdpartyAccount
  class ThirdpartyAccount < Account
    include RailsCom::Account::ThirdpartyAccount
  end
end
