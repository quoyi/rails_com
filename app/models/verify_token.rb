unless defined? VerifyToken
  class VerifyToken < ApplicationRecord
    include RailsCom::VerifyToken
  end
end
