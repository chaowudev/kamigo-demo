class Received < ApplicationRecord
  validates :channel_id, :text, presence: true
end
