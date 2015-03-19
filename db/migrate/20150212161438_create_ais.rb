class CreateAis < ActiveRecord::Migration
  def change
    create_table :ais do |t|
      t.string :name
      t.string :language
      t.string :location
      t.references :user, index: true
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :ties, default: 0
      
      t.timestamps null: false
    end
    add_index :ais, [:user_id, :created_at]
    add_foreign_key :ais, :users
  end
end
