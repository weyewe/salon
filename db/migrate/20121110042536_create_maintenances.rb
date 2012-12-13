class CreateMaintenances < ActiveRecord::Migration
  def change
    create_table :maintenances do |t|
      t.integer :sales_order_id  
      t.integer :vehicle_id 
      
      t.timestamps
    end
  end
end
