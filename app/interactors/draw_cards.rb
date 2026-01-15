# 両プレイヤーがカードを1枚ドローする
class DrawCards
  include Interactor

  def call
    game = context.game
    # ゲームが終了している場合は何もしない
    return if game.finished?

    game.game_players.order(:id).each do |player|
      drawn_card = player.draw_card!

      # デッキが空で引けなかった場合に敗北
      if drawn_card.nil?
        game.finish_deck_death!(player)
        break
      end
    end
  end
end
