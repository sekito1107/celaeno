class MatchmakingController < ApplicationController
  def create
    deck_type = current_user.selected_deck
    game = current_user.join_matchmaking!(deck_type)

    if game
      redirect_to game_path(game)
    else
      redirect_to matchmaking_path
    end
  end

  def show
  end

  def destroy
    current_user.leave_matchmaking!
    redirect_to lobby_path
  end
end
