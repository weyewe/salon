class CreateStockMigrations < ActiveRecord::Migration
  def change
    create_table :stock_migrations do |t|
      
      t.string :code # migration code. uniq.. no double 
      
      t.boolean :is_deleted , :default => false 
      t.integer :year
      t.integer :month 
      t.integer :item_id
      t.integer :creator_id
      t.timestamps
    end
  end
end
