class GameChannel < ApplicationCable::Channel
  def subscribed
    @game = Game.find_by(id: params[:game_id])

    # プレイヤーのみ接続可能
    if @game && @game.game_players.exists?(user: current_user)
      stream_for @game
    else
      reject
    end
  end

  def unsubscribed
    # 切断時の処理 (将来的にAFKタイマーなどを実装する場合に使用)
  end
end
