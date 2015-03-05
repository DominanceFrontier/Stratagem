class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.string :mario
      t.string :luigi
      t.string :result, default: "open"
      t.text :state, default: "[[\" \",\" \",\" \"],[\" \",\" \",\" \"],[\" \",\" \",\" \"]]"
      t.text :moveHistory, default: "[]"

      t.timestamps null: false
    end
  end
end
