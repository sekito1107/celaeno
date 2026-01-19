class ChangeMovesCostNotNull < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE moves SET cost = 0 WHERE cost IS NULL"
    change_column :moves, :cost, :integer, null: false, default: 0
  end

  def down
    change_column :moves, :cost, :integer, null: true, default: nil
  end
end
