class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :game, index:true
      t.references :mario, polymorphic: true, index: true
      t.references :luigi, polymorphic: true, index: true
      t.string :result, default: "open"
      t.integer :time_alloted
      t.text :state, default: "[[\" \",\" \",\" \"],[\" \",\" \",\" \"],[\" \",\" \",\" \"]]"
      t.text :moveHistory, default: "[]"

      t.timestamps null: false
    end
  end
end
