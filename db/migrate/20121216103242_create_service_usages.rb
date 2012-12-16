class CreateServiceUsages < ActiveRecord::Migration
  def change
    create_table :service_usages do |t|
      t.integer :service_item_id 
      t.integer :compatibility_id 
      t.integer :service_component_id 
      t.integer :sales_order_id   

      t.timestamps
    end
  end
end
