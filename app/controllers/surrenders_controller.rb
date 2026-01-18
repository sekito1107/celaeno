class SurrendersController < ApplicationController
  include GameContextLoader
  include GameActionHelper

  def create
    @game_player.surrender!

    result = GameActionResult.success(message: "降伏しました。")
    handle_game_action(result)
  end
end
