class StockMigration < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :item
  
  
  
  
  
  def stock_entry 
    stock_migration = self 
    StockEntry.find(:first, :conditions => {
      :source_document => stock_migration.class.to_s, 
      :source_document_id => stock_migration.id ,
      :entry_case =>  STOCK_ENTRY_CASE[:initial_migration], 
      :is_addition => true 
    })
  end
  
  def StockMigration.create_migration(employee, item)
    a = StockMigration.new
    year = DateTime.now.year 
    month = DateTime.now.month  
    total_stock_migration_created_this_month = StockMigration.where(:year => year.to_i, :month => month.to_i).count  
    
    a.code =  'SM/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_stock_migration_created_this_month + 1 ).to_s 
    
    a.creator_id = employee.id
    a.item_id = item.id 
    a.save 
    return a 
  end
  
  
   
  
  def StockMigration.create_item_migration(employee, item, quantity,  base_price_per_piece) 
    if item.stock_mutations.count != 0 
      return nil
    end
    
    
    ActiveRecord::Base.transaction do
    
      new_stock_entry = StockEntry.new 
      new_stock_entry.creator_id = employee.id
      new_stock_entry.quantity = quantity
      new_stock_entry.base_price_per_piece  = base_price_per_piece
    
      new_stock_entry.item_id  = item.id 
    
      new_stock_entry.entry_case =  STOCK_ENTRY_CASE[:initial_migration]
      new_stock_entry.source_document = self.to_s 
    
      # if quantity <= 0 
      #     new_stock_entry.errors.add(:quantity , "Quantity harus setidaknya 1" ) 
      #     return new_stock_entry
      #   end
      #   
      #   if base_price_per_piece <= BigDecimal('0')
      #     new_stock_entry.errors.add(:base_price_per_piece , "Harga harus setidaknya 1" ) 
      #     return new_stock_entry
      #   end
      #   
      #   
    
      if not new_stock_entry.valid?
        return new_stock_entry
      end
      
    
      stock_migration = self.create_migration(employee, item) 
    
    
      new_stock_entry.source_document_id = stock_migration.id  
      new_stock_entry.save 
    
    
      # StockMutation.create_stock_migration(employee, new_stock_entry, stock_migration )
     
      item.add_stock_and_recalculate_average_cost_post_stock_entry_addition( new_stock_entry ) 
          
          # create the StockMutation
      StockMutation.create(
        :quantity            => quantity  ,
        :stock_entry_id      =>  new_stock_entry.id ,
        :creator_id          =>  employee.id ,
        :source_document_entry_id  =>  stock_migration.id   ,
        :source_document_id  =>  stock_migration.id  ,
        :source_document_entry     =>  stock_migration.class.to_s,
        :source_document    =>  stock_migration.class.to_s,
        :mutation_case      => MUTATION_CASE[:stock_migration],
        :mutation_status => MUTATION_STATUS[:addition],
        :item_id => item.id
      )
    
    
      return new_stock_entry  
    end
    
  end
  
  
end
