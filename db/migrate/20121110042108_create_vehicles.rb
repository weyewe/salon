class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      
      t.boolean :is_customer_registered, :default => false  
      #if not registered, it doesn't have customer attached to it 
      # hence, customer id = nil 
      
      t.string :id_code  
      # plat number => unique car identification 
      
      t.integer :customer_id # if it is registered, it will be linked back to the customer 
      
      t.boolean :is_deleted , :default => false 
      t.timestamps
    end
  end
end
