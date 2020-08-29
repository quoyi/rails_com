unless defined? Account
  class Account < ApplicationRecord
    include RailsCom::Account
  end
end
