class CreateSalesReturns < ActiveRecord::Migration
  # target business: over the counter.. won't be long before the return 
  def change
    create_table :sales_returns do |t|
      t.integer :sales_order_id 
      t.string :code 
      t.integer :creator_id 
      
      
      
      t.integer :customer_id
      
      
      t.integer :year
      t.integer :month 
      t.boolean :is_deleted , :default => false 
      t.integer :deleter_id 
      
      t.boolean :is_confirmed , :default => false 
      t.integer :confirmator_id  
      t.datetime :confirmed_datetime
      
      t.decimal :admin_fee , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value

      t.timestamps
    end
  end
end
