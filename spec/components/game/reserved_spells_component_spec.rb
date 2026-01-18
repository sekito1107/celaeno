# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game::ReservedSpellsComponent, type: :component do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:card_def) { create(:card) }
  let(:game_player) { create(:game_player, user: user, game: game) }

  let(:card1) { create(:game_card, game: game, user: user, game_player: game_player, card: card_def) }
  let(:card2) { create(:game_card, game: game, user: user, game_player: game_player, card: card_def) }
  let(:cards) { [ card1, card2 ] }

  it "予約呪文ゾーンが正しくレンダリングされること" do
    render_inline(described_class.new(cards: cards))

    expect(page).to have_css(".reserved-spells-zone")
    expect(page).to have_css(".zone-label", text: "RITUAL")
    expect(page).to have_css(".reserved-cards-stack")
    expect(page).to have_css(".reserved-card-wrapper", count: 2)
  end

  it "各カードが正しいインデックスでレンダリングされること" do
    render_inline(described_class.new(cards: cards))

    wrappers = page.all(".reserved-card-wrapper")
    expect(wrappers[0][:style]).to include("--stack-index: 0")
    expect(wrappers[1][:style]).to include("--stack-index: 1")

    expect(wrappers[0]).to have_css(".card-wrapper")
    expect(wrappers[1]).to have_css(".card-wrapper")
  end
end
