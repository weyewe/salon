class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string :name 
      t.string :code 
      
      t.string :mobile_phone 
      t.text :address 
      
      
      t.integer :creator_id 
      t.integer :year
      t.integer :month 
      t.boolean :is_deleted , :default => false 
      
      t.timestamps
    end
  end
end
