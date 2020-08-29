unless defined? UserTagged
  class UserTagged < ApplicationRecord
    include RailsCom::UserTagged
  end
end
