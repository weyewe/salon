class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.integer :vendor_id 
      t.integer :creator_id 
      
      t.string :code 
      
      t.integer :year
      t.integer :month 
      t.boolean :is_deleted , :default => false 
      
      t.boolean :is_confirmed , :default => false 
      t.integer :confirmator_id  
      
      t.boolean :is_paid, :default => false 
      t.integer :paid_declarator_id

      t.timestamps
    end
  end
end
