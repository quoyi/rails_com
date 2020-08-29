module RailsCom::UserTag
  extend ActiveSupport::Concern
  included do
    attribute :name, :string
    attribute :user_taggeds_count, :integer, default: 0

    belongs_to :organ, optional: true
    belongs_to :tagging, polymorphic: true, optional: true
    has_many :user_taggeds, dependent: :destroy

    validates :name, presence: true
  end
end
