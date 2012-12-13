class CreatePurchaseEntries < ActiveRecord::Migration
  def change
    create_table :purchase_entries do |t|
      t.integer :purchase_order_id
      t.integer :item_id  
      
      t.integer :quantity # only per piece # if service, it is 1 by default  
      
      
      # the one entered by the owner 
      t.decimal :price_per_piece , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      
      # deduced 
      t.decimal :total_purchase_price , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      # what is the use case of total sales price? 
      
      
      t.boolean :is_deleted , :default => false 


      t.integer :sales_order_id

      t.timestamps
    end
  end
end
