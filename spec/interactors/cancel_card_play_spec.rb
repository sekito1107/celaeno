require 'rails_helper'

RSpec.describe CancelCardPlay, type: :interactor do
  describe '.call' do
    let(:game) { create(:game) }
    let(:user) { create(:user) }
    let(:turn) { create(:turn, game: game, turn_number: 1) }
    let(:game_player) { create(:game_player, game: game, user: user) }

    # 予約済みのカード（フィールドにある状態）
    let(:card) { create(:card, cost: "1") }
    let(:game_card) { create(:game_card, game: game, user: user, game_player: game_player, card: card, location: :board, position: :center) }

    # 関連するMove
    let!(:move) { create(:move, turn: turn, user: user, game_card: game_card, cost: 1) }

    subject(:context) { described_class.call(game: game, user: user, game_card_id: game_card.id) }

    before do
      allow(game).to receive(:current_turn_number).and_return(1)
    end

    context '正常系' do
      it '成功すること' do
        expect(context).to be_a_success
      end

      it 'Moveが削除されること' do
        expect { context }.to change { Move.count }.by(-1)
      end

      it 'カードが手札に戻ること' do
        context
        game_card.reload
        expect(game_card.location).to eq("hand")
        expect(game_card.position).to be_nil
      end

      context '重複したMoveが存在する場合（競合状態のシミュレーション）' do
        before do
          create(:move, turn: turn, user: user, game_card: game_card, cost: 1)
        end

        it '全てのMoveが削除されること' do
          expect(Move.where(game_card: game_card).count).to eq(2)
          context
          expect(Move.where(game_card: game_card).count).to eq(0)
        end
      end
    end

    context '異常系' do
      context '他人のカードをキャンセルしようとした場合' do
        let(:other_user) { create(:user) }
        subject(:context) { described_class.call(game: game, user: other_user, game_card_id: game_card.id) }

        it '失敗すること' do
          expect(context).to be_a_failure
          expect(context.message).to eq("キャンセル可能なアクションが見つかりません")
        end
      end

      context '存在しないカードIDの場合' do
        subject(:context) { described_class.call(game: game, user: user, game_card_id: 99999) }

        it '失敗すること' do
          expect(context).to be_a_failure
        end
      end
    end
  end
end
