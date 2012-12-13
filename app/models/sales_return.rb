class SalesReturn < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :sales_order
  has_many :sales_return_entries 
  validates_presence_of :sales_order_id 
  
  def self.create_sales_return( employee, sales_order )   
    return nil if sales_order.nil? 
    
    a = SalesReturn.new
    year = DateTime.now.year 
    month = DateTime.now.month  
    total_sales_returns_created_this_month = SalesReturn.where(:year => year.to_i, :month => month.to_i).count  

    code =  'SR/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_sales_returns_created_this_month + 1 ).to_s 
                        
    a.year = year
    a.month = month 
    
    
    if sales_order.nil? or not sales_order.is_confirmed? 
      a.errors.add(:sales_order_id , "Sales invoice is invalid" ) 
      return a
    end
    
    a.sales_order_id = sales_order.id
       
    
    a.creator_id = employee.id 
        
    a.code = code 
    a.save 
    return a 
  end
  
  
  def active_sales_return_entries
    self.sales_return_entries.where(:is_deleted => false ).order("created_at ASC")
  end
  
  
  def total_amount_to_be_reimbursed
    self.active_sales_return_entries.sum("total_reimburse_price") - self.admin_fee
  end
  
  def max_returnable_for(item)
    # get the sales entry for that item
    # quantity of sales entry - sales_entry.sales_return_entries.
                    # where(:sales_return => {:is_confirmed => true }).sum('quantity')
                    
    sales_entry = self.sales_order.sales_entry_for_item( item)
    return nil if sales_entry.nil? 
    
    sales_entry.max_returnable_quantity 
  end
  
  
  def sales_entry_for(item)
    self.sales_order.sales_entry_for_item( item)
  end
  
  def sales_price_for(item)
    sales_entry = self.sales_entry_for(item)
    sales_entry.selling_price_per_piece
  end
  
  
  
  def sales_return_entry_for_item( item)
    sales_entry = self.sales_entry_for(item)
    
    self.active_sales_return_entries.find(:first, :conditions => { 
      :sales_entry_id => sales_entry.id  
    })  
  end
  
  def duplicate_sales_return_entry_for_item?(item)
    sales_entry = self.sales_entry_for(item)
    
    self.active_sales_return_entries.where( 
      :sales_entry_id => sales_entry.id  
    ).count >= 2
  end
  
  
  def has_sales_return_entry_for_item?(item)
    not sales_return_entry_for_item( item).nil?
  end
  
  def add_sales_return_entry_item( item, quantity,reimburse_price_per_piece )
    sales_entry = sales_entry_for(item) 
    return nil if sales_entry.nil?
    
    new_sales_return_entry = SalesReturnEntry.new 
    new_sales_return_entry.sales_entry_id = sales_entry.id 
    new_sales_return_entry.quantity = quantity 
    new_sales_return_entry.reimburse_price_per_piece = reimburse_price_per_piece  
    new_sales_return_entry.sales_return_id  = self.id  
    new_sales_return_entry.total_reimburse_price  = quantity * reimburse_price_per_piece
    
    
    
    
    # if self.has_sales_return_entry_for_item?(item ) or sales_entry.nil?
    #   new_sales_return_entry.errors.add(:quantity , "Quantity must be more than 1 and less than  #{self.max_returnable_for(item)}" ) 
    #   return new_sales_return_entry 
    # end
    # 
    # if quantity.nil? or quantity <= 0 or quantity > self.max_returnable_for(item)
    #   new_sales_return_entry.errors.add(:quantity , "Quantity must be more than 1 and less than  #{self.max_returnable_for(item)}" ) 
    #   return new_sales_return_entry
    # end
    # 
    # if reimburse_price_per_piece < BigDecimal('0')
    #   new_sales_return_entry.errors.add(:reimburse_price_per_piece , "Pengembalian uang tidak boleh negative" ) 
    #   return new_sales_return_entry
    # end
    
    
    new_sales_return_entry.save 
    return new_sales_return_entry
  end
  
  def delete_sales_return_entry(sales_return_entry)
    if self.is_confirmed == true 
      return nil
    end 
    
    sales_return_entry = SalesReturnEntry.find(:first, :conditions => {
      :id => sales_return_entry.id, :sales_return_id => self.id
    })
    
    sales_return_entry.delete
  end
  
  def confirm_return(employee)
    return nil if self.is_confirmed? 
    return nil if self.active_sales_return_entries.count ==0 
    
     # check whether there is enough item for all sales entry 
     # if not, cancel the transaction, and tell them: which item that is not available 
     # | Item Name| Requested | Available |  
    
    ActiveRecord::Base.transaction do
      
      self.active_sales_return_entries.each do |sales_return_entry|
        StockMutation.recover_stock_from_sales_return( employee, sales_return_entry)  
      end
      
      self.is_confirmed = true 
      self.confirmator_id = employee.id
      self.confirmed_datetime = DateTime.now  
      self.save
    end
  end
  
=begin
  TRACKING STOCK MUTATION AND STOCK ENTRY
=end
  def stock_mutations
    StockMutation.where(  
      :source_document_id  =>  self.id  , 
      :source_document    =>  self.class.to_s,
      :mutation_case      => MUTATION_CASE[:sales_return],
      :mutation_status => MUTATION_STATUS[:addition], 
      :item_status => ITEM_STATUS[:ready]
    ).order("created_at ASC")
   
  end
  
  def stock_entries
    stock_entry_id_list  = self.stock_mutations.map{|x| x.stock_entry_id }.uniq
    StockEntry.where(:id =>stock_entry_id_list ).order("created_at ASC") 
  end
  
  
=begin
  Sales Invoice Printing
=end
  def printed_sales_return_code
    self.code.gsub('/','-')
  end

  
  
end
