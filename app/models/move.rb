class Move < ApplicationRecord
  belongs_to :turn
  belongs_to :user

  belongs_to :game_card

  belongs_to :target_game_card, class_name: "GameCard", optional: true
  belongs_to :target_player, class_name: "GamePlayer", optional: true

  enum :action_type, { play: 0, attack: 1, spell: 2 }, prefix: true
  enum :position, { left: 0, center: 1, right: 2 }, prefix: false

  validates :position, presence: true, inclusion: { in: positions.keys }, if: :action_type_play?
  validates :position, absence: true, if: :action_type_spell?
  validates :position, absence: true, if: :action_type_attack?
end
