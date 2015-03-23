class CreateAis < ActiveRecord::Migration
  def change
    create_table :ais do |t|
      t.string :name
      t.string :language
      t.string :location
      t.references :user, index: true
      
      t.timestamps null: false
    end
    add_index :ais, [:user_id, :created_at]
    add_foreign_key :ais, :users
  end
end
