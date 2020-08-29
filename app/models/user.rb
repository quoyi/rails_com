unless defined? User
  class User < ApplicationRecord
    include RailsCom::User
  end
end
