class AddCostToMoves < ActiveRecord::Migration[8.1]
  def change
    add_column :moves, :cost, :integer
  end
end
