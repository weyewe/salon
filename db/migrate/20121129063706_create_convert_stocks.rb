class CreateConvertStocks < ActiveRecord::Migration
  def change
    create_table :convert_stocks do |t|
      t.integer :stock_conversion_id 
      t.integer :creator_id 
      
      t.integer :source_quantity , :default => 0 
      
      t.integer :year
      t.integer :month 
      
      
      t.boolean :is_deleted , :default => false 
      t.integer :deleter_id 
      
      
       

      t.timestamps
    end
  end
end
