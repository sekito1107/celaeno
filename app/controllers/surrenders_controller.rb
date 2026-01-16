class SurrendersController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    game_player = current_user.game_players.find_by(game: game)

    if game_player
      game_player.surrender!
      redirect_to lobby_path, notice: "降伏しました。"
    else
      redirect_to lobby_path, alert: "ゲームに参加していません。"
    end
  end
end
