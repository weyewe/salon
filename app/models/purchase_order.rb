class PurchaseOrder < ActiveRecord::Base 
  belongs_to :vendor 
  has_many :purchase_entries
  
  validates_presence_of :vendor_id, :creator_id 
  
  def self.create_purchase_order( employee, vendor  )  
    
    a = PurchaseOrder.new
    if employee.nil?
      a.errors.add(:creator_id , "No creator.. fake?" ) 
      return a 
    end
    
    if vendor.nil?
      a.errors.add(:vendor_id , "Harus memilih vendor untuk membuat purchase order" ) 
      return a 
    end
    
    year = DateTime.now.year 
    month = DateTime.now.month  
    total_created_this_month = PurchaseOrder.where(:year => year.to_i, :month => month.to_i).count  

    code =  'PI/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_created_this_month + 1 ).to_s 
                        
    a.year = year
    a.month = month 
    a.vendor_id = vendor.id  
    a.creator_id = employee.id 
        
    a.code = code 
    a.save 
    return a 
  end
  
  def active_purchase_entries
    self.purchase_entries.where(:is_deleted => false ).order("created_at ASC")
  end
  
  def purchase_entry_for_item( item)
    self.purchase_entries.where(:item_id => item.id).first 
  end 
  
  
  def has_purchase_entry_for_item?(item)
    not purchase_entry_for_item( item).nil?
  end
  
  # @has_no_errors  = @project.errors.messages.length == 0 
  def add_purchase_entry_item(item,  quantity,   price_per_piece )
    past_item = self.purchase_entry_for_item(item)   
    
    if not past_item.nil?  
      past_item.errors.add(:duplicate_entry , "There is exact item in the sales invoice list" ) 
      return past_item 
    end
    
     
    
    # rule for sales entry creation: max stock?  no indent?. just sell whatever we have now 
    # MVP minimum viable product
    new_object = PurchaseEntry.new
    new_object.purchase_order_id = self.id
    new_object.item_id = item.id 
    new_object.quantity = quantity  
    new_object.price_per_piece = price_per_piece
    
    
    
    if not quantity.present? or quantity <=  0
      new_object.errors.add(:quantity , "Quantity harus setidaknya 1" ) 
      return new_object
    end
     
    if not price_per_piece.present? or price_per_piece <=  BigDecimal('0')
      new_object.errors.add(:price_per_piece , "Harga beli harus lebih besar dari 0 rupiah" ) 
      return new_object
    end
    
    new_object.total_purchase_price = quantity  * price_per_piece 
    new_object.save   
  
    return new_object  
  end
  
  def delete_purchase_entry( purchase_entry ) 
    if self.is_confirmed == true 
      return nil
    end 
    
    purchase_entry = PurchaseEntry.find(:first, :conditions => {
      :id => purchase_entry.id, :purchase_order_id => self.id
    })
    
    purchase_entry.delete
  end
  
  # on sales order confirm, deduct stock level 
  
  def total_amount_to_be_paid
    self.active_purchase_entries.sum("total_purchase_price")
  end
  
  
  def confirm_purchase( employee)  
    return nil if self.is_confirmed? 
    return nil if self.active_purchase_entries.count == 0 
    
    ActiveRecord::Base.transaction do
      
      self.active_purchase_entries.each do |purchase_entry| 
        purchase_entry.create_stock_entry(employee) 
      end
      
      self.is_confirmed = true 
      self.confirmator_id = employee.id 
      self.save
    end 
  end
  
=begin
  TRACKING ALL STOCK ENTRIES AND STOCK MUTATIONS
=end

  def stock_mutations
     
    StockMutation.where(  
      :source_document_id  =>  self.id  , 
      :source_document    =>  self.class.to_s,
      :mutation_case      => MUTATION_CASE[:purchase_order],
      :mutation_status => MUTATION_STATUS[:addition], 
      :item_status => ITEM_STATUS[:ready]
    ).order("created_at ASC")
  end

  def stock_entries
    stock_entry_id_list  = self.stock_mutations.map{|x| x.stock_entry_id }.uniq
    StockEntry.where(:id =>stock_entry_id_list ).order("created_at ASC") 
  end
  
  
end
