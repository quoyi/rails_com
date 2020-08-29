unless defined? UserTag
  class UserTag < ApplicationRecord
    include RailsCom::UserTag
  end
end
