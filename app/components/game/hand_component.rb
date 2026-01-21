# frozen_string_literal: true

class Game::HandComponent < ApplicationComponent
  def initialize(game_player:, viewer:)
    @game_player = game_player
    @viewer = viewer
  end

  def cards
    @cards ||= if @game_player.association(:game_cards).loaded?
      @game_player.game_cards.select(&:location_hand?).sort_by { |c| c.position_in_stack || 0 }
    else
      @game_player.hand
    end
  end

  def viewer_is_owner?
    @viewer == @game_player.user
  end

  def render?
    @game_player.present?
  end
end
