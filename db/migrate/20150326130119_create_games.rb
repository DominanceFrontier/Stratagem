class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.string :path
      t.string :p1_symbol
      t.string :p2_symbol
      
      t.timestamps null: false
    end
  end
end
