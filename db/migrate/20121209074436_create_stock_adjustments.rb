class CreateStockAdjustments < ActiveRecord::Migration
  def change
    create_table :stock_adjustments do |t|
      t.integer :creator_id  
      t.string :code
      
      t.integer :item_id 
      t.integer :ready_quantity
      t.integer :physical_quantity  
      
      t.integer :adjustment_quantity
      t.integer :adjustment_case 
   

      t.timestamps
    end
  end
end
