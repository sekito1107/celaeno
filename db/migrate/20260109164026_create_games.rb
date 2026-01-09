class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.integer :status
      t.integer :turn_count
      t.string :finish_reason
      t.datetime :finished_at
      t.references :winner, null: false, foreign_key: true
      t.references :loser, null: false, foreign_key: true
      t.integer :seed

      t.timestamps
    end
  end
end
