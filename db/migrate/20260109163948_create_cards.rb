class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.string :name
      t.integer :card_type
      t.string :cost
      t.string :attack
      t.integer :hp
      t.string :keyword
      t.integer :sanity_threshold
      t.string :madness_param
      t.text :madness_text
      t.text :description
      t.text :flavor_text
      t.string :image_name

      t.timestamps
    end
  end
end
