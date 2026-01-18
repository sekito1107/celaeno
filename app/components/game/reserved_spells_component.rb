# frozen_string_literal: true

class Game::ReservedSpellsComponent < ApplicationComponent
  def initialize(cards:)
    @cards = cards
  end
end
