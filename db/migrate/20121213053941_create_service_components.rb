class CreateServiceComponents < ActiveRecord::Migration
  def change
    create_table :service_components do |t|
      t.integer :service_id 
      
      t.string :name 
      
      t.boolean :is_deleted, :default => false 

      t.timestamps
    end
  end
end
