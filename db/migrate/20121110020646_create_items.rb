class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      # item has several phases: ready to be sold
      # scrap : broken, can't be returned to supplier 
      # pending_return : can be returned to supplier. but not yet delivered 
      t.integer :creator_id 
      t.integer :ready , :default => 0 
      t.integer :scrap , :default => 0 
      t.integer :pending_return, :default => 0  

      t.string :name 
      
      t.integer :category_id 
      
      # it is updated whenever a stock is inputted to the system
      t.decimal :average_cost , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      # for alfindo, there is average cogs per kg 
      # updated whenever there is stock entry addition
      
      t.decimal :recommended_selling_price , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      t.boolean :is_deleted , :default => false 
      # t.integer :initial_quantity 
      #  t.decimal :initial_base_price , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      #  
      t.timestamps
    end
  end
end
