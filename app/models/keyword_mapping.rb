class KeywordMapping < ApplicationRecord
  validates :keyword, :message, presence: true
end
