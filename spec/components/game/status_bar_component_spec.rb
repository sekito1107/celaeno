# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game::StatusBarComponent, type: :component do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:game_player) { create(:game_player, game: game, user: user, hp: 20, san: 20) }

  before do
    # 定数が定義されていることを確認 (テスト内で定数に依存するため)
    stub_const("GamePlayer::DEFAULT_HP", 20)
    stub_const("GamePlayer::DEFAULT_SAN", 20)
  end

  context "通常状態の場合" do
    it "HPとSANが正しく表示されること" do
      render_inline(described_class.new(game_player: game_player))

      expect(page).to have_css(".hero-status-container")
      expect(page).to have_css(".hp-badge .stat-value", text: "20")
      expect(page).to have_css(".san-badge .stat-value", text: "20")
    end
  end

  context "ダメージを受けている場合" do
    before { game_player.update(hp: 10, san: 5) }

    it "数値が正しく更新されていること" do
      render_inline(described_class.new(game_player: game_player))
      expect(page).to have_css(".hp-badge .stat-value", text: "10")
      expect(page).to have_css(".san-badge .stat-value", text: "5")
    end
  end

  context "発狂状態の場合 (SAN <= 0)" do
    before { game_player.update(san: 0) }

    it "insaneクラスが付与されていること" do
      render_inline(described_class.new(game_player: game_player))
      # sanity_level_class returns "sanity-critical" for san <= 5
      expect(page).to have_css(".hero-status-container.sanity-critical")
    end
  end

  context "ユニット召喚数の表示" do
    let!(:turn) { create(:turn, game: game, turn_number: 1) }

    it "召喚数と上限が正しく表示されること" do
      render_inline(described_class.new(game_player: game_player))
      expect(page).to have_css(".unit-badge .stat-value", text: "0/1")
    end

    context "ユニットを召喚している場合" do
      let(:unit_card) { create(:card, :unit) }
      let(:game_card) { create(:game_card, game: game, card: unit_card, user: user, game_player: game_player) }

      before do
        create(:move, turn: turn, user: user, game_card: game_card)
      end

      it "召喚数が更新されること" do
        render_inline(described_class.new(game_player: game_player))
        expect(page).to have_css(".unit-badge .stat-value", text: "1/1")
      end
    end
  end
end
