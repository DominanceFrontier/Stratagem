class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.references :mario, polymorphic: true, index: true
      t.references :luigi, polymorphic: true, index: true
      t.string :result, default: "open"

      t.timestamps null: false
    end
  end
end
