unless defined? EmailAccount
  class EmailAccount < Account
    include RailsCom::Account::EmailAccount
  end
end
