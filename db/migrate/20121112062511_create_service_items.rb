class CreateServiceItems < ActiveRecord::Migration
  def change
    create_table :service_items do |t|
      t.integer :service_id 
      t.integer :sales_entry_id
      # the price info is in the member 
      
      t.integer :vehicle_id 
      
      t.boolean :is_deleted, :default => false 
      
      t.boolean :is_confirmed, :default => false 
      
      t.decimal :commission_per_employee , :precision => 11, :scale => 2 , :default => 0
      t.datetime :confirmed_datetime 

      t.timestamps
    end
  end
end
