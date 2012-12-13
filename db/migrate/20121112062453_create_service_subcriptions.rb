class CreateServiceSubcriptions < ActiveRecord::Migration
  def change
    create_table :service_subcriptions do |t|
      t.integer :service_item_id 
      t.integer :employee_id 
      
      t.integer :is_active , :default => false 
      # when it is active, it will be counted toward employee's service delivered profit sharing 
 
      t.timestamps
    end
  end
end
