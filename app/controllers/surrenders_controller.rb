class SurrendersController < ApplicationController
  def create
    game_player = current_user.game_players.find_by(game_id: params[:game_id])

    if game_player
      game_player.surrender!
      redirect_to lobby_path, notice: "降伏しました。"
    else
      redirect_to lobby_path, alert: "ゲームに参加していません。"
    end
  end
end
