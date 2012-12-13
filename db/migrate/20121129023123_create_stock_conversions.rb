class CreateStockConversions < ActiveRecord::Migration
  def change
    create_table :stock_conversions do |t|
      t.string :code
      
      t.integer :conversion_status, :default => CONVERSION_STATUS[:disassembly] 
      
      t.boolean :is_deleted, :default => false 

      t.timestamps
    end
  end
end
