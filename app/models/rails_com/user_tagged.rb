module RailsCom::UserTagged
  extend ActiveSupport::Concern
  included do
    belongs_to :user
    belongs_to :user_tag, counter_cache: true
  end
end
