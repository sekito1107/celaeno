class PayResolvePhaseCosts
  include Interactor

  def call
    game = context.game
    turn = game.turns.find_by(turn_number: game.current_turn_number)

    # このターンにプレイされたカード（Move）を取得
    moves = turn.moves.includes(:game_card, :user)

    # プレイヤーごとにコストを計算して消費
    moves.group_by(&:user).each do |user, user_moves|
      game_player = game.game_players.find_by(user: user)
      next unless game_player

      total_cost = user_moves.sum { |m| m.cost || 0 }

      if total_cost > 0
        game_player.pay_cost!(total_cost)
        game.check_player_death!(game_player)
      end
    end
  end
end
