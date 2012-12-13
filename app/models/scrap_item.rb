class ScrapItem < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :stock_mutations 
  validate :quantity_not_zero,
          :item_is_valid 
  belongs_to :item  
  
  def quantity_not_zero
    item = self.item
    if self.quantity <= 0 or self.quantity > item.ready 
      errors.add(:quantity , "Invalid Quantity. Setidaknya 1 dan tidak lebih dari #{item.ready}") 
    end
  end
  
  def item_is_valid
    item = self.item
    
    if item.is_deleted?  
      errors.add(:item_id , "Invalid Item" )  
    end 
  end
  
  
  def ScrapItem.generate_scrap_code( item)
    datetime  =  DateTime.now
    year = datetime.year 
    month = datetime.month   
    total_scrap_item_created_this_month = ScrapItem.where(:created_at => datetime.beginning_of_month..datetime.end_of_month   ).count  
    
    code =  'SCR/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_scrap_item_created_this_month + 1 ).to_s 
    
    
    return code
  end
  
  def self.create_scrap( employee, item, quantity) 
    
    new_scrap_item = ScrapItem.new 
    new_scrap_item.item_id = item.id 
    new_scrap_item.quantity = quantity 
    new_scrap_item.creator_id = employee.id  
    
    
    if not new_scrap_item.valid?
      return new_scrap_item
    end
    
    
    new_scrap_item.code = ScrapItem.generate_scrap_code(item) 
    new_scrap_item.save 
    
    ActiveRecord::Base.transaction do 
      StockMutation.deduct_ready_stock_add_scrap_item(
              employee, new_scrap_item
            ) 
    end
    
    return new_scrap_item 
  end
  
  def self.first_available_stock(item) 
    # FOR FIFO 
    # we will replace the first item entering scrap 
    ScrapItem.where(:is_finished => false, :item_id => item.id ).order("id ASC").first 
  end
  
  def unexchanged_quantity
    self.quantity - self.exchanged_quantity
  end
  
  def exchange_scrap( quantity  )
    self.exchanged_quantity += quantity
    self.save 
  end
   
=begin
  STOCK MUTATIONS, when scrapping item 
=end
  def stock_mutations_for_ready_item_deduction 
    StockMutation.where(
      :scrap_item_id => self.id,  
      :source_document_entry_id  =>  self.id  ,
      :source_document_id  =>  self.id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.class.to_s,  
      :mutation_case      => MUTATION_CASE[:scrap_item],
      :mutation_status => MUTATION_STATUS[:deduction], 
      :item_status => ITEM_STATUS[:ready] 
    )
  end
  
  def deducted_stock_entries
    stock_entry_id_list = self.stock_mutations_for_ready_item_deduction.map{|x| x.stock_entry_id }.uniq
    StockEntry.where(:id => stock_entry_id_list)
  end
  
  def unrecovered_deducted_stock_entries
    deducted_stock_entries.where{ scrapped_quantity.not_eq 0 }.order("id ASC")
  end
  
  
  def stock_mutations_for_scrap_item_addition
    StockMutation.where( 
      :scrap_item_id => self.id,  
      :source_document_entry_id  =>  self.id  ,
      :source_document_id  =>  self.id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.class.to_s, 
      
      :mutation_case      => MUTATION_CASE[:scrap_item],
      :mutation_status => MUTATION_STATUS[:addition], 
      :item_status => ITEM_STATUS[:scrap]
    )
  end
  
=begin
  STOCK MUTATION WHEN EXCHANGE SCRAP ITEM 
=end
  def stock_mutations_for_ready_item_addition 
    StockMutation.where(
      :scrap_item_id => self.id,   
      :source_document_entry     =>  ExchangeScrapItem.to_s,
      :source_document    =>  ExchangeScrapItem.to_s,  
      :mutation_case      => MUTATION_CASE[:scrap_item_replacement],
      :mutation_status => MUTATION_STATUS[:addition], 
      :item_status => ITEM_STATUS[:ready] 
    )
  end
  
  def added_stock_entries
    stock_entry_id_list = self.stock_mutations_for_ready_item_addition.map{|x| x.stock_entry_id }
    StockEntry.where(:id => stock_entry_id_list)
  end
  
  def finish_recovered_stock_entries
    added_stock_entries.where{ (scrapped_quantity.eq 0 ) & (is_finished.eq true )}.order("id ASC")
  end
  
  
  def stock_mutations_for_scrap_item_deduction  
    StockMutation.where( 
      :scrap_item_id => self.id,   
      :source_document_entry     =>  ExchangeScrapItem.to_s,
      :source_document    =>  ExchangeScrapItem.to_s, 
      
      :mutation_case      => MUTATION_CASE[:scrap_item_replacement],
      :mutation_status => MUTATION_STATUS[:deduction], 
      :item_status => ITEM_STATUS[:scrap]
    )
  end
end
