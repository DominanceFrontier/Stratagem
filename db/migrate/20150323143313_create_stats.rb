class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.references :player, polymorphic: true, index: true
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :ties, default: 0
      t.integer :illegals, default: 0
      
      t.timestamps null: false
    end
  end
end
