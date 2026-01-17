# frozen_string_literal: true

class Game::StatusBarComponent < ApplicationComponent
  def initialize(game_player:)
    @game_player = game_player
  end

  def hp
    @game_player.hp
  end

  def max_hp
    @game_player.max_hp
  end

  def san
    @game_player.san
  end

  def max_san
    @game_player.max_san
  end

  def insane?
    @game_player.insane?
  end

  def sanity_level_class
    case san
    when 0..5
      "sanity-critical"
    when 6..10
      "sanity-low"
    when 11..15
      "sanity-warning"
    else
      "sanity-normal"
    end
  end
end
