class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|
      
      t.string :code # sales order code  # year/month/ number 
      t.integer :creator_id 
      
  
      
      
      
      # for the indexing.. we might not need this for now
      # t.integer :year 
      # t.integer :month 
      # t.integer :yday 
      
      t.boolean :is_registered_customer  , :default => false 
      t.integer :customer_id # we can make 2 sales order: registered / non registered 
      # non registered => we don't need the client info.. 
        # non registered => can be only spare part purchase or including the service. for the service, 
        # we need to know the vehicle ID.
        
        
      t.boolean :is_registered_vehicle , :default => false 
      t.integer :vehicle_id 
        
        
      t.integer :year
      t.integer :month 
      t.boolean :is_deleted , :default => false 
      t.integer :deleter_id 
      
      t.boolean :is_confirmed , :default => false 
      t.integer :confirmator_id  
      t.datetime :confirmed_datetime 
      
      t.boolean :is_paid, :default => false 
      t.integer :paid_declarator_id 
      
      t.timestamps
    end
  end
end
