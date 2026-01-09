class Move < ApplicationRecord
  belongs_to :turn
  belongs_to :user
  belongs_to :card
end
