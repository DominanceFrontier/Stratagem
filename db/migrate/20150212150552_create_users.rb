class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :username
      t.string :email
      t.string :password_digest
      t.string :reset_digest
      t.datetime :reset_sent_at
      t.integer :wins, default: 0
      t.integer :losses, default: 0
      t.integer :ties, default: 0

      
      t.timestamps null: false
    end
  end
end
