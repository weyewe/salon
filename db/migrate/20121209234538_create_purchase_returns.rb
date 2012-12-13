class CreatePurchaseReturns < ActiveRecord::Migration
  def change
    create_table :purchase_returns do |t|
      t.integer :creator_id 
      
      t.string :code
      t.integer :item_id 
      t.integer :quantity 
      
      t.integer :purchase_order_id
      

      t.timestamps
    end
  end
end
