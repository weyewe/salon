class CreateSalesReturnEntries < ActiveRecord::Migration
  def change
    create_table :sales_return_entries do |t|
      t.integer :sales_entry_id
      t.integer :sales_return_id 
      
      t.integer :quantity
      
      t.decimal :reimburse_price_per_piece , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      t.decimal :total_reimburse_price , :precision => 11, :scale => 2 , :default => 0
      t.boolean :is_deleted , :default => false 

      t.timestamps
    end
  end
end
