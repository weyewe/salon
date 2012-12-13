class CreateConversionEntries < ActiveRecord::Migration
  def change
    create_table :conversion_entries do |t|
      t.integer :stock_conversion_id 
      t.integer :item_id 
      
      t.integer :quantity 
      t.integer :entry_status , :default => STOCK_CONVERSION_ENTRY_STATUS[:source]
      t.boolean :is_deleted, :default => false 

      t.timestamps
    end
  end
end
