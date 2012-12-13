class PurchaseEntry < ActiveRecord::Base
  attr_accessible :item_id,  :price_per_piece, :quantity
  belongs_to :purchase_order 
  belongs_to :item 
  
  def update_total_purchase_price 
    self.total_purchase_price = self.price_per_piece *  self.quantity
    self.save 
  end
  
  def delete 
    if self.purchase_order.is_confirmed 
      return nil
    end
    
    self.is_deleted = true 
    self.save   
  end
  
  def update_item(quantity, price_per_piece) 
    return nil if self.purchase_order.is_confirmed?
    
    if not quantity.present? or quantity <=  0
      self.errors.add(:quantity , "Quantity harus setidaknya 1" ) 
      return self
    end
     
    if not price_per_piece.present? or price_per_piece <=  BigDecimal('0')
      self.errors.add(:price_per_piece , "Harga jual harus lebih besar dari 0 rupiah" ) 
      return self
    end
    
    self.quantity = quantity 
    self.price_per_piece = price_per_piece
    self.total_purchase_price = quantity  * price_per_piece 
    self.save
    
    return self
  end
  
  def create_stock_entry(employee)
    new_stock_entry = StockEntry.new 
    item = self.item 
    
    new_stock_entry.creator_id = employee.id
    new_stock_entry.quantity = self.quantity
    new_stock_entry.base_price_per_piece  = self.price_per_piece
    
    
    new_stock_entry.item_id  =  item.id 
    
    
    
    new_stock_entry.entry_case =  STOCK_ENTRY_CASE[:purchase]
    new_stock_entry.source_document = self.class.to_s 
    new_stock_entry.source_document_id = self.id 
    new_stock_entry.save 
    
     
    
    # where is the stock mutation ?
    StockMutation.create(
      :quantity            => self.quantity  ,
      :stock_entry_id      =>  new_stock_entry.id ,
      :creator_id          =>  employee.id ,
      :source_document_entry_id  =>  self.id   ,
      :source_document_id  =>  self.purchase_order_id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.purchase_order.class.to_s,
      :mutation_case      => MUTATION_CASE[:purchase_order],
      :mutation_status => MUTATION_STATUS[:addition],
      :item_id => item.id
    )
    
    
     
    item.add_stock_and_recalculate_average_cost_post_stock_entry_addition( new_stock_entry )
    
    return new_stock_entry
    
  end
  
  
  def stock_mutations
    StockMutation.where( 
      :source_document_entry_id  =>  self.id ,
      :source_document_id  =>  self.purchase_order_id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.purchase_order.class.to_s,
      :mutation_case      => MUTATION_CASE[:purchase_order],
      :mutation_status => MUTATION_STATUS[:addition],
      :item_id =>  self.entry_id  ,
      :item_status => ITEM_STATUS[:ready]
    ).order("created_at ASC")
  end
  
  def stock_entries
    stock_entry_id_list  = self.stock_mutations.map{|x| x.stock_entry_id }.uniq 
    StockEntry.where(:id =>stock_entry_id_list ).order("created_at ASC")
  end
  
  
end
