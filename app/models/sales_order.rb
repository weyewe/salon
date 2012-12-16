class SalesOrder < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :customer 
  belongs_to :vehicle
  has_many :maintenances  # no, we don't go with the maintenance. stick with the MVP, willy! 
  has_many :sales_entries 
  has_many :sales_returns 
  has_many :service_usages 
  # has_many :sales_entries, :through => :stock_entry_usages  # can be service or item sold 
  # has_many :stock_entry_usages
  
  # has_many :services, :through => :service_items 
  #   has_many :service_items 
  
  # validates_presence_of :is_registered_customer
  # validates_presence_of :is_registered_vehicle
  
  def self.create_sales_order( employee, customer  )  
    a = SalesOrder.new
    year = DateTime.now.year 
    month = DateTime.now.month  
    total_sales_orders_created_this_month = SalesOrder.where(:year => year.to_i, :month => month.to_i).count  

    code =  'SI/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_sales_orders_created_this_month + 1 ).to_s 
                        
    a.year = year
    a.month = month 
    
   
    if not customer.nil?
      a.customer_id = customer.id   
    end
    
    
    a.creator_id = employee.id 
        
    a.code = code 
    a.save 
    return a 
  end
  
  

  
  
  
  
  def active_sales_entries
    self.sales_entries.where(:is_deleted => false ).order("created_at ASC")
  end
  
  def sales_entry_for_item( item)
    self.active_sales_entries.find(:first, :conditions => {
      :entry_case => SALES_ENTRY_CASE[:item],
      :entry_id => item.id  
    })  
  end 
  
  def sales_entries_for_item( item ) 
    self.active_sales_entries.where{
      (entry_case.eq SALES_ENTRY_CASE[:item]) & 
      ( entry_id.eq item.id )  & 
      (id.not_eq nil )
    }
  end
  
  
  def has_sales_entry_for_item?(item)
    not sales_entry_for_item( item).nil?
  end
  
  # @has_no_errors  = @project.errors.messages.length == 0 
  def add_sales_entry_item(item,  quantity,   price_per_piece )
       
    
    # puts "Gonna return if the past item is not nil\n"*10
    #   puts "#{past_item.class}"
    #   puts "sales_order.id #{self.id}"
    #   puts "total sales entries: #{self.active_sales_entries.count}"
    
    # past_item = self.sales_entry_for_item(item)
    
    # if not past_item.nil?  and past_item.is_product? 
    #   past_item.errors.add(:duplicate_entry , "There is exact item in the sales invoice list" ) 
    #   return past_item 
    # end
    
    
    
    
    # puts "Gonna create new sales entry\n"*10
    
    # rule for sales entry creation: max stock?  no indent?. just sell whatever we have now 
    # MVP minimum viable product
    new_object = SalesEntry.new
    new_object.sales_order_id = self.id
    new_object.entry_id = item.id 
    new_object.entry_case = SALES_ENTRY_CASE[:item] 
    new_object.quantity = quantity  
    new_object.selling_price_per_piece = price_per_piece
    
    
    
    # if not quantity.present? or quantity <=  0
    #   new_object.errors.add(:quantity , "Quantity harus setidaknya 1. Ready stock:  #{item.ready}") 
    #   return new_object
    # end
    
    # if quantity > item.ready
    #   new_object.errors.add(:quantity , "Quantity harus setidaknya 1. Ready stock:  #{item.ready}" ) 
    #   return new_object
    # end
    #  
    # if not price_per_piece.present? or price_per_piece <=  BigDecimal('0')
    #   new_object.errors.add(:selling_price_per_piece , "Harga jual harus lebih besar dari 0 rupiah" ) 
    #   return new_object
    # end
    
    if not new_object.valid?
      return new_object
    end
    
    new_object.total_sales_price = quantity  * price_per_piece 
    new_object.save   
  
    return new_object  
  end
  
  
  
  def update_customer( customer ) 
    return nil if  self.is_confirmed == true  
    if not customer.nil? 
      self.customer_id = customer.id 
    else
      self.customer_id = nil 
    end
    self.save
  end
  
  def add_sales_entry_service(service_object, price  )
    new_object = SalesEntry.new 
    new_object.entry_id = service_object.id   
    new_object.entry_case = SALES_ENTRY_CASE[:service] 
    new_object.quantity = 1 
    new_object.selling_price_per_piece = price
    new_object.sales_order_id = self.id 
    new_object.total_sales_price = price
    
    
    
    
    if price.nil? or price <= BigDecimal('0')
      new_object.errors.add(:selling_price_per_piece , "Harga tidak boleh kurang atau sama dengan  0" ) 
      return new_object
    end 
    
    new_object.save 
    # gonna create service usage as well 
    new_object.generate_service_item 
    
    return new_object
  end
 
  def delete_sales_entry( sales_entry ) 
    if self.is_confirmed == true 
      return nil
    end 
    
    sales_entry = SalesEntry.find(:first, :conditions => {
      :id => sales_entry.id, :sales_order_id => self.id
    })
    
    sales_entry.delete
  end
  
  # on sales order confirm, deduct stock level 
  
  def total_amount_to_be_paid
    self.active_sales_entries.sum("total_sales_price")
  end
  
  def confirm_sales( employee)  
    return nil if self.is_confirmed? 
    return nil if self.active_sales_entries.count ==0 
    
     # check whether there is enough item for all sales entry 
     # if not, cancel the transaction, and tell them: which item that is not available 
     # | Item Name| Requested | Available |  
    
    ActiveRecord::Base.transaction do
      
      self.active_sales_entries.each do |sales_entry|
        
        if sales_entry.is_product?
          sales_entry.deduct_stock(employee)
        elsif sales_entry.is_service?
          sales_entry.confirm_service_item
        end
      end
      
      self.is_confirmed = true 
      self.confirmator_id = employee.id
      self.confirmed_datetime = DateTime.now  
      self.save
    end 
  end
  
  def delete(employee)
    return nil if self.is_confirmed? 
    
    self.is_deleted = true 
    self.deleter_id = employee.id 
    self.save 
    
  end
  
=begin
  TRACKING ALL STOCK ENTRIES AND STOCK MUTATIONS
=end

  def stock_mutations
    StockMutation.where(  
      :source_document_id  =>  self.id  , 
      :source_document    =>  self.class.to_s,
      :mutation_case      => MUTATION_CASE[:sales_order],
      :mutation_status => MUTATION_STATUS[:deduction], 
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
  def printed_sales_invoice_code
    self.code.gsub('/','-')
  end
  
  def calculated_vat
    BigDecimal("0")
  end
  
  def calculated_delivery_charges
    BigDecimal("0")
  end
  
  def calculated_sales_tax
    BigDecimal('0')
  end
  
=begin
  Sales Return Creation
=end
  def item_id_list  
    self.active_sales_entries.where(:entry_case => SALES_ENTRY_CASE[:item]  ).map{|x| x.entry_id} 
  end
  
  
end
