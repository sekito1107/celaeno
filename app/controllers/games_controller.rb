class GamesController < ApplicationController
  include GameAuthenticatable

  layout "game"

  def show
    # N+1対策: ゲームに関連するプレイヤー、カード、GameCardを事前にロード
    @game = Game.includes(game_players: { game_cards: :card }).find(params[:id])

    @game_player = @game.game_players.find { |gp| gp.user_id == current_user.id }
    @opponent_game_player = @game.game_players.find { |gp| gp.user_id != current_user.id }

    # GameAuthenticatable のチェックを通すためのインスタンス変数は再利用
    # (includes を使ってロードし直した @game を使うため)

    # 現在のターンのMoveを取得してコストを紐付ける
    current_turn = @game.turns.find_by(turn_number: @game.current_turn_number)
    moves = current_turn&.moves&.where(user: current_user) || []

    @resolving_cards = @game.game_cards.select do |card|
      if card.location_resolving? && card.user_id == current_user.id && !card.unit?
        move = moves.find { |m| m.game_card_id == card.id }
        card.pending_cost = move&.cost if move
        true
      end
    end
  end
end
