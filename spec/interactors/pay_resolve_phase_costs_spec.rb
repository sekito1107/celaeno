require 'rails_helper'

RSpec.describe PayResolvePhaseCosts, type: :interactor do
  describe '.call' do
    let(:game) { create(:game) }
    let(:user) { create(:user) }
    let(:game_player) { create(:game_player, game: game, user: user, san: 20) }
    let(:turn) { create(:turn, game: game, turn_number: 1) }

    before do
      allow(game).to receive(:current_turn_number).and_return(turn.turn_number)
      # Game references turn via has_many turns

      # Setup moves with costs
      card = create(:card)
      game_card = create(:game_card, game: game, game_player: game_player, user: user, card: card)

      # Move 1: Cost 3
      create(:move, turn: turn, user: user, game_card: game_card, action_type: :play, position: :left, cost: 3)
      # Move 2: Cost 2
      create(:move, turn: turn, user: user, game_card: game_card, action_type: :play, position: :right, cost: 2)
    end

    subject(:context) { described_class.call(game: game) }

    it '全てのMoveのコスト合計分SANを消費すること' do
      expect { context }.to change { game_player.reload.san }.by(-5)
    end

    context 'SANが足りない場合' do
      before do
        game_player.update!(san: 4)
      end

      it 'SANが0になり、死亡判定が行われること' do
        expect(game).to receive(:check_player_death!).with(game_player)
        context
        expect(game_player.reload.san).to eq 0
      end
    end

    context 'コストがない場合' do
      before do
        Move.destroy_all
      end

      it 'SANは消費されないこと' do
        expect { context }.not_to change { game_player.reload.san }
      end
    end
  end
end
