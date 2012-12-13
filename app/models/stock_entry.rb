class StockEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :item
  has_many :stock_mutations 
  
  validates_presence_of :quantity, :base_price_per_piece
  validate :quantity_not_less_than_zero, :base_price_per_piece_not_less_than_zero
  
  def quantity_not_less_than_zero
    if quantity <= 0 
      errors.add(:quantity , "Quantity harus setidaknya 1" )  
    end
  end
  
  def base_price_per_piece_not_less_than_zero
    if base_price_per_piece <= BigDecimal('0') 
      errors.add(:base_price_per_piece , "Harga tidak boleh kurang atau sama dengan  0" )  
    end
  end
  
  
  def available_quantity  
    quantity - used_quantity 
  end
  
  
  # used in stock entry deduction 
  def update_usage(served_quantity) 
    self.used_quantity += served_quantity    
    self.save  
    
    self.mark_as_finished
    
    item = self.item 
    item.deduct_ready_quantity(served_quantity ) 
    
    return self  
  end
  
  
  #  used in sales return =>  recovering the ready item, from the sold 
  def recover_usage(quantity_to_be_recovered)
    self.used_quantity -= quantity_to_be_recovered 
    self.save  
     
    self.unmark_as_finished
    
    
    
    item = self.item 
    item.add_ready_quantity( quantity_to_be_recovered ) 
    
    return self 
  end

  def self.first_available_stock(item) 
    # FOR FIFO , we will devour the first available item
    StockEntry.where(:is_finished => false, :item_id => item.id ).order("id ASC").first 
  end
  
  def stock_migration
    if self.entry_case == STOCK_ENTRY_CASE[:initial_migration]
      StockMigration.find_by_id self.source_document_id
    else
      return nil
    end
  end
  
  
  # MAYBE WE DON't NEED THIS SHIT? since we have the squeel 
  def mark_as_finished 
    if self.used_quantity + self.scrapped_quantity == self.quantity
      self.is_finished = true 
    end
    self.save
  end
  
  def unmark_as_finished 
    if self.used_quantity + self.scrapped_quantity < self.quantity
      self.is_finished = false 
    end
    self.save
  end
  
  
=begin
  SCRAP RELATED : READY -> SCRAP
=end 

  def perform_item_scrapping( served_quantity) 
    self.scrapped_quantity += served_quantity  
    self.save 
    
    self.mark_as_finished 
    
    item.add_scrap_quantity( served_quantity )  
    
    return self
  end
  
=begin
  SCRAP EXCHANGE RELATED : SCRAP -> READY
=end

  def perform_scrap_item_replacement( scrap_recover_quantity) 
    self.scrapped_quantity -= scrap_recover_quantity  
    self.save 
  
    self.unmark_as_finished  
  
    item.deduct_scrap_quantity( scrap_recover_quantity )  
  
    return self
  end
  
end
