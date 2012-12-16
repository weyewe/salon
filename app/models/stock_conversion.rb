class StockConversion < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :conversion_entries
  has_many :convert_stocks
  
  def self.active_stock_conversions
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def self.create_one_to_one( employee, source_item, target_item, quantity ) 
    new_stock_conversion = StockConversion.new 
    
    
    if source_item.nil? or target_item.nil? or not quantity.present?
      new_stock_conversion.errors.add(:source_item_id , "Tidak boleh kosong" ) 
      new_stock_conversion.errors.add(:target_item_id , "Tidak boleh kosong" ) 
      new_stock_conversion.errors.add(:target_quantity , "Tidak boleh kosong" ) 
      return new_stock_conversion
    end
    
    # a.errors[:name]
    if source_item.id == target_item.id or source_item.is_deleted? or target_item.is_deleted? 
      new_stock_conversion.errors.add(:source_item_id , "Source Item dan Target Item tidak boleh sama" ) 
      return new_stock_conversion
    end
    
    if quantity <= 0 
      new_stock_conversion.errors.add(:target_quantity , "Quantity harus setidaknya 1" ) 
      return new_stock_conversion
    end
    
    new_stock_conversion.conversion_status = CONVERSION_STATUS[:disassembly] 
    
    
    new_stock_conversion.save 
    new_stock_conversion.code ='SC/' + 
                                "#{new_stock_conversion.id}/" +  
                                "#{source_item.id}/" + 
                                "#{target_item.id}"
    
    new_stock_conversion.save 
     
    new_stock_conversion.create_conversion_entry( source_item, 1 , STOCK_CONVERSION_ENTRY_STATUS[:source] ) 
    new_stock_conversion.create_conversion_entry( target_item, quantity , STOCK_CONVERSION_ENTRY_STATUS[:target] ) 
    return new_stock_conversion
  end
  
  def create_conversion_entry( item, quantity, status )
    new_conversion_entry = ConversionEntry.new 
    new_conversion_entry.stock_conversion_id = self.id 
    new_conversion_entry.item_id = item.id 
    new_conversion_entry.quantity = quantity 
    new_conversion_entry.entry_status = status 
    new_conversion_entry.save  
  end
  
  def one_to_one_source
    self.conversion_entries.where( 
      :is_deleted => false ,
      :entry_status => STOCK_CONVERSION_ENTRY_STATUS[:source]
    ).first 
  end
  
  def one_to_one_target
    self.conversion_entries.where( 
      :is_deleted => false ,
      :entry_status => STOCK_CONVERSION_ENTRY_STATUS[:target]
    ).first 
  end
  
=begin
  CREATE STOCK CONVERSION 
=end

  def execute_convert_stock_one_on_one( employee, quantity) 
    source = self.one_to_one_source 
    source_item = source.item 
    
    new_convert_stock = ConvertStock.new  
    new_convert_stock.source_quantity = quantity 
    new_convert_stock.creator_id = employee.id 
    new_convert_stock.stock_conversion_id = self.id 
    today_datetime = DateTime.now 
    new_convert_stock.year  = today_datetime.year 
    new_convert_stock.month =  today_datetime.year 
    
    
  
    if not quantity.present? or quantity <= 0 or quantity > source_item.ready # if it is not one to one -> quantity*source.quantity > source_item.ready 
      new_convert_stock.errors.add(:source_quantity , 
        "Jumlah Konversi harus setidaknya 1, dan tidak boleh lebih dari #{source_item.ready}" ) 
      return new_convert_stock 
    end
    
    new_convert_stock.save  
    
    # create stock entry
    new_convert_stock.execute_conversion_one_on_one(employee)   
    # create stock mutation 
  end
  
  def active_conversion_entries
    self.conversion_entries.where(:is_deleted => false )
  end
  
  def delete
    self.is_deleted = true 
    self.save 
  end
  
end
