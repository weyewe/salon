class ExchangeScrapItem < ActiveRecord::Base
  # attr_accessible :title, :body
  
  belongs_to :item 
  validate :quantity_must_not_exceed_scrap_quantity
  
  def quantity_must_not_exceed_scrap_quantity
    item = self.item
    if self.quantity <= 0 or self.quantity > item.scrap 
      errors.add(:quantity , "Invalid Quantity. Setidaknya 1 dan tidak lebih dari #{item.scrap}") 
    end
  end
  
  
  def ExchangeScrapItem.generate_exchange_scrap_code( item)
    datetime  =  DateTime.now
    year = datetime.year 
    month = datetime.month   
    total_scrap_item_created_this_month = ExchangeScrapItem.where(:created_at => datetime.beginning_of_month..datetime.end_of_month   ).count  
    
    code =  'SCR/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_scrap_item_created_this_month + 1 ).to_s 
    
    
    return code
  end
  
  
  def self.create_exchange_scrap( employee, item, quantity) 
    
    # return nil if quantity > item.scrap 
    
    new_ex_scrap_item = ExchangeScrapItem.new 
    new_ex_scrap_item.item_id = item.id 
    new_ex_scrap_item.quantity = quantity 
    new_ex_scrap_item.creator_id = employee.id 
    
    
    if item.is_deleted?  
      new_ex_scrap_item.errors.add(:item_id , "Invalid Item" ) 
      return new_ex_scrap_item
    end
    
    if quantity <= 0 or quantity > item.scrap 
      new_ex_scrap_item.errors.add(:quantity , "Invalid Quantity. Setidaknya 1 dan tidak lebih dari #{item.scrap}" ) 
      return new_ex_scrap_item
    end
    
    
    new_ex_scrap_item.code = ExchangeScrapItem.generate_exchange_scrap_code( item) 
    new_ex_scrap_item.save 
    
    ActiveRecord::Base.transaction do 
      StockMutation.deduct_scrap_add_ready_stock(
              employee, new_ex_scrap_item  ) 
    end
    
    return new_ex_scrap_item 
  end
  
=begin
  POST EXCHANGE: STOCK MUTATION TO DEDUCT scrap and ADD ready 
=end

  def stock_mutations_to_deduct_scrap_item 
    StockMutation.where( 
      :source_document_entry_id  =>  self.id  ,
      :source_document_id  =>  self.id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.class.to_s,
      :mutation_case      => MUTATION_CASE[:scrap_item_replacement],
      :mutation_status => MUTATION_STATUS[:deduction], 
      :item_status => ITEM_STATUS[:scrap]
    )
  end
  
  def stock_mutations_to_add_ready
    StockMutation.where( 
      :source_document_entry_id  =>  self.id  ,
      :source_document_id  =>  self.id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.class.to_s,
      :mutation_case      => MUTATION_CASE[:scrap_item_replacement],
      :mutation_status => MUTATION_STATUS[:addition], 
      :item_status => ITEM_STATUS[:ready]
    )
  end
end
