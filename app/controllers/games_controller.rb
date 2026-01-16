class GamesController < ApplicationController
  include GameAuthenticatable

  layout "game"

  def show
    # @game is already set by GameAuthenticatable
  end
end
