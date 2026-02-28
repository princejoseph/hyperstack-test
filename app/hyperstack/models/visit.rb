class Visit < ApplicationRecord
  scope :recent, -> { order(created_at: :desc).limit(10) }
end
