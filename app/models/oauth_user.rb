unless defined? OauthUser
  class OauthUser < ApplicationRecord
    include RailsCom::OauthUser
  end
end
