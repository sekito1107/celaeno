# scripts/setup_empty_game.rb

unless Rails.env.development? || Rails.env.test?
  abort "This script is allowed only in development/test environments."
end

# 1. Find Users
user1 = User.find_by(email_address: "test1@example.com")
user2 = User.find_by(email_address: "test2@example.com")

unless user1 && user2
  puts "Error: Test users not found. Run bin/rails db:seed first."
  exit 1
end

puts "Found Users: #{user1.name} (Player), #{user2.name} (Opponent)"

# 2. Cleanup old active games for these users to avoid confusion
game_ids = Game.where(status: [ :matching, :playing ])
               .joins(:game_players)
               .where(game_players: { user_id: [ user1.id, user2.id ] })
               .distinct
               .pluck(:id)

if game_ids.any?
  puts "Cleaning up old games: #{game_ids.inspect}"

  # 1. Nullify self-referential FKs to break cycles
  GameCard.where(game_id: game_ids).update_all(target_game_card_id: nil)

  # 2. Delete child records (leaf nodes)
  GameCardModifier.where(game_card_id: GameCard.where(game_id: game_ids)).delete_all
  Move.where(turn_id: Turn.where(game_id: game_ids)).delete_all
  BattleLog.where(turn_id: Turn.where(game_id: game_ids)).delete_all

  # 3. Delete intermediate records
  GameCard.where(game_id: game_ids).delete_all
  Turn.where(game_id: game_ids).delete_all
  GamePlayer.where(game_id: game_ids).delete_all

  # 4. Delete root
  Game.where(id: game_ids).delete_all
end

# 3. Create Game
game = Game.create!(status: :playing)
puts "Created Game ID: #{game.id}"

# 4. Create Players
p1 = GamePlayer.create!(game: game, user: user1, role: :host, hp: 20, san: 20)
p2 = GamePlayer.create!(game: game, user: user2, role: :guest, hp: 20, san: 20)

puts "Created Players"

# 4.5 Create First Turn
Turn.create!(game: game, turn_number: 1, status: :planning)
puts "Created First Turn"

# 5. Populate Cards
cards = Card.all.to_a
if cards.empty?
  puts "Error: No cards found in DB."
  exit 1
end

def add_cards(player, cards, location, count, position: nil)
  count.times do |i|
    # For board, only pick unit cards
    candidate_cards = (location == :board) ? cards.select { |c| c.card_type == "unit" } : cards

    # Fallback if no units found (unlikely)
    candidate_cards = cards if candidate_cards.empty?

    card_def = candidate_cards.sample
    GameCard.create!(
      game: player.game,
      user: player.user,
      game_player: player,
      card: card_def,
      location: location,
      position_in_stack: (location == :hand || location == :deck) ? (i + (position.is_a?(Integer) ? position : 0)) : nil,
      position: (location == :board) ? position : nil
    )
  end
end

puts "Populating decks and hands (Empty Board)..."

# Player 1 - Hand has Units to summon
# Ensure at least 3 Units in hand
unit_cards = cards.select { |c| c.card_type == "unit" }.sample(3)
unit_cards.each_with_index do |card, i|
  GameCard.create!(
      game: p1.game,
      user: p1.user,
      game_player: p1,
      card: card,
      location: :hand,
      position_in_stack: i
  )
end

add_cards(p1, cards, :hand, 2, position: 3) # Add random cards
add_cards(p1, cards, :deck, 15, position: 0)

# NO CARDS ON BOARD for Player 1

# Player 2 (Opponent)
add_cards(p2, cards, :hand, 5)
add_cards(p2, cards, :deck, 15)
# NO CARDS ON BOARD for Player 2 (or maybe 1 for context, but requests was "empty slots")

puts "Game Setup Complete (Empty Board)!"
puts "---------------------------------------------------"
puts "Access URL: http://localhost:3000/games/#{game.id}"
puts "Login as:   #{user1.email_address} / testpass123"
puts "---------------------------------------------------"
