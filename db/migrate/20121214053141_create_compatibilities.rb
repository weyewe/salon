class CreateCompatibilities < ActiveRecord::Migration
  def change
    create_table :compatibilities do |t|
      t.integer :service_component_id
      t.integer :item_id 
      
      t.integer :quantity 
      t.boolean :is_deleted ,:default => false 
      
      
      t.timestamps
    end
  end
end
