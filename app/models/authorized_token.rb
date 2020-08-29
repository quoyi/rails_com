unless defined? AuthorizedToken
  class AuthorizedToken < ApplicationRecord
    include RailsCom::AuthorizedToken
  end
end
