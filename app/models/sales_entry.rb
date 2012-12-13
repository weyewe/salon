class SalesEntry < ActiveRecord::Base
  attr_accessible :entry_id, :entry_case, :selling_price_per_piece, :quantity
  belongs_to :sales_order 
  belongs_to :maintenance 
  
  has_one :service_item 
  has_one :service, :through  => :service_item 
  
  has_many :sales_return_entries
  
  validate  :quantity_must_greater_than_zero, 
            :selling_price_per_piece_must_be_greater_than_zero,
            :product_sales_entry_has_no_past_item 
            
  def quantity_must_greater_than_zero
    if not quantity.present? or quantity <= 0 
      errors.add(:quantity , "Quantity harus setidaknya 1" )  
    end
  end
  
  def selling_price_per_piece_must_be_greater_than_zero
    if not selling_price_per_piece.present? or selling_price_per_piece <= BigDecimal('0') 
      errors.add(:selling_price_per_piece , "Harga harus lebih besar dari 0" )  
    end
  end
  
  def product_sales_entry_has_no_past_item
    sales_order = SalesOrder.find_by_id self.sales_order_id 
    
    # puts "Inside the validation sales entry. sales_order #{sales_order}"
    if self.is_product? 
      
      # puts "YEAH, I AM IS PRODUCT\n"*10
      item = Item.find_by_id self.entry_id 
      # puts "item: #{item}"
      past_item_sales_entries = sales_order.sales_entries_for_item( item )
    
    # it seems that eventhough it is not saved yet, it is still appearing on the result 
      # if not past_item.nil?   and not past_item.persisted?
      
      # puts "Total sales entries: #{past_item_sales_entries.count}\n"*5
      if past_item_sales_entries.count >  1 
        errors.add(:duplicate_entry , "There is exact item in the sales invoice list" )  
      end
    end
  end
  
  
  def update_total_sales_price 
    self.total_sales_price = self.selling_price_per_piece *  self.quantity
    self.save 
  end
  
  def delete 
    return nil if self.sales_order.is_confirmed?
    
    self.is_deleted = true 
    self.save  
    
    if self.is_service?
      service_item = self.service_item
      service_item.delete 
    end
  end
  
  def deduct_stock(employee)
    
    
    requested_quantity = self.quantity
    # if quantity > item.ready_quantity
    # return nil -> correct way: create indent request 
    # end 
    supplied_quantity = 0
    
    ready_quantity = self.item.ready 
    
    if ready_quantity < requested_quantity 
      raise ActiveRecord::Rollback, "Can't be executed. Not enough Item in the stock" 
    end
    # puts "#{self.item.name }, Ready: #{ready_quantity}, requested: #{requested_quantity}\n"*10
    
    StockMutation.deduct_ready_stock(
            employee, 
            self.quantity,  # quantity 
            self.item ,  # item 
            self.sales_order, #source_document
            self, # source_document_entry,
            MUTATION_CASE[:sales_order], # mutation_case 
            MUTATION_STATUS[:deduction] # mutation_status
         
          )
     
  end
  
  def stock_mutations
    StockMutation.where( 
      :source_document_entry_id  =>  self.id ,
      :source_document_id  =>  self.sales_order_id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.sales_order.class.to_s,
      :mutation_case      => MUTATION_CASE[:sales_order],
      :mutation_status => MUTATION_STATUS[:deduction],
      :item_id =>  self.entry_id  ,
      :item_status => ITEM_STATUS[:ready]
    ) 
  end
  
  def stock_entries
    stock_entry_id_list  = self.stock_mutations.map{|x| x.stock_entry_id }.uniq 
    StockEntry.where(:id =>stock_entry_id_list ) 
  end
  
  def stock_mutation_for( stock_entry )
    self.stock_mutations.where(:stock_entry_id => stock_entry.id ).first
  end
  
  def is_product?
    self.entry_case == SALES_ENTRY_CASE[:item]
  end
  
  def is_service?
    self.entry_case == SALES_ENTRY_CASE[:service]
  end
  
  def item
    if self.is_product?
      return Item.find_by_id self.entry_id
    else self.is_service?
      return Service.find_by_id self.entry_id
    end
  end
  
  
  def generate_service_item 
    if self.entry_case != SALES_ENTRY_CASE[:service]
      return nil 
    end
    
    ServiceItem.create :service_id => self.entry_id, :sales_entry_id => self.id  
  end
   
  
  def add_employees( employee_list )  
    return nil if self.entry_case !=  SALES_ENTRY_CASE[:service]
    return nil if employee_list.length == 0  
    
    service_item = self.service_item 
    service_item.add_employees_participation( employee_list )
  end
  
=begin
  Sales Order Creation
=end
  def total_price
    self.quantity * self.selling_price_per_piece
  end
  
=begin
  UPDATE SALES ENTRY
=end
  def update_item(quantity, price_per_piece) 
    return nil if self.sales_order.is_confirmed?
    item = self.item
     
    if not quantity.present? or quantity <=  0 or quantity > item.ready 
      self.errors.add(:quantity , "Quantity harus setidaknya 1 dan lebih kecil dari #{item.ready}" ) 
      return self
    end
     
    if not price_per_piece.present? or price_per_piece <=  BigDecimal('0')
      self.errors.add(:selling_price_per_piece , "Harga jual harus lebih besar dari 0 rupiah" ) 
      return self
    end
    
    self.quantity = quantity 
    self.selling_price_per_piece = price_per_piece
    self.total_sales_price = quantity  * price_per_piece 
    self.save
    
    return self
  end
  
  
  def add_employee(employee)
    service_item = self.service_item 
    service_item.add_employee_participation( employee )
  end
  
  def update_service( price, employee ) 
    return nil if self.sales_order.is_confirmed?
    
    if not price.present? or price <=  BigDecimal('0')
      self.errors.add(:selling_price_per_piece , "Harga jual harus lebih besar dari 0 rupiah" ) 
      return self
    end
     
    self.selling_price_per_piece = price
    self.total_sales_price =price
    self.save
    
    if not employee.nil? and not employee.is_deleted 
      self.add_employee(employee) 
    end  
    
    return self 
  end
  
=begin
  Update Service Details
=end
  def update_service_details(vehicle, item_list )
    return nil if not self.is_service?
    
    service_item = self.service_item
    service_item.vehicle_id = vehicle.id 
    service_item.save 
    
    service_item.create_replacement_items( item_list   )  
  end
  
=begin
  ON SALES ORDER CONFIRMATION
=end

  def confirm_service_item
    if self.service_item.nil?
      return nil
    end
     
    service_item = self.service_item 
    # manifest the commission per employee
    service_item.commission_per_employee = service_item.service.commission_per_employee
    service_item.is_confirmed = true 
    service_item.confirmed_datetime = DateTime.now 
    service_item.save 
  end
  
=begin
  ON SALES_RETURN
=end
  def max_returnable_quantity
    self.quantity - self.sales_return_entries.where(:is_deleted => false) .joins(:sales_return).
                            where(:sales_return => {:is_confirmed => true}).sum('quantity')
  end
end
