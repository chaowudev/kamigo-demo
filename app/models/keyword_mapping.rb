class KeywordMapping < ApplicationRecord
  validates :keyword, :message, :channel_id, presence: true
end
