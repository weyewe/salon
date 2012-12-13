class CreateStockMutations < ActiveRecord::Migration
  def change
    create_table :stock_mutations do |t|
      t.integer :quantity 
      
      # for those intersected mutations from scrap -> stock entry, or vice versa... 
      # scrap_item_id is not nil , stock_entry_id is_not nil 
      t.integer :scrap_item_id , :default => nil
      t.integer :stock_entry_id  , :default => nil
      
      t.integer :creator_id  
      t.integer :source_document_id
      
      t.string  :source_document_entry 
      t.integer :source_document_entry_id
      
      t.string :source_document
      t.integer :source_document_id   
      
      t.integer :mutation_case 
      
      t.integer :mutation_status, :default => MUTATION_STATUS[:deduction] 
      
      t.integer :item_status, :default => ITEM_STATUS[:ready] ## the items being changed.. if it is in deducting the ready.. use ready 
      t.integer :item_id  
      t.timestamps
    end
  end
end
