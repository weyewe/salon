class CreateScrapItems < ActiveRecord::Migration
  def change
    create_table :scrap_items do |t|
      t.integer :creator_id 
      
      t.string :code
      t.integer :item_id 
      t.integer :quantity 
      
      t.boolean :is_finished, :default => false # finish => means replaced
      t.integer :exchanged_quantity , :default => 0 

      t.timestamps
    end
  end
end
