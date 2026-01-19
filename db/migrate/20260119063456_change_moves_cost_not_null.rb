class ChangeMovesCostNotNull < ActiveRecord::Migration[8.1]
  def up
    Move.where(cost: nil).update_all(cost: 0)
    change_column :moves, :cost, :integer, null: false, default: 0
  end

  def down
    change_column :moves, :cost, :integer, null: true, default: nil
  end
end
