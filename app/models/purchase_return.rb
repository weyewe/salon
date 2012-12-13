class PurchaseReturn < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :item
  validates_presence_of :item_id, :creator_id 
  validate :quantity_non_zero
  
  def quantity_non_zero
    item = self.item
    if self.quantity <= 0 or self.quantity > item.ready 
      errors.add(:quantity , "Invalid Quantity. Setidaknya 1 dan tidak lebih dari #{item.ready}") 
    end
  end
  
  def PurchaseReturn.generate_return_code( item)
    datetime  =  DateTime.now
    year = datetime.year 
    month = datetime.month   
    total_created_this_month = PurchaseReturn.where(:created_at => datetime.beginning_of_month..datetime.end_of_month   ).count  
    
    code =  'PRT/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_created_this_month + 1 ).to_s 
    
    
    return code
  end
  
  
  
  def self.create_item_return(employee, item , quantity ) 
    
    ActiveRecord::Base.transaction do
      ready_quantity = item.ready 
      new_purchase_return = PurchaseReturn.new 
      new_purchase_return.quantity = quantity  
      new_purchase_return.creator_id = employee.id 
      new_purchase_return.item_id = item.id 
      new_purchase_return.code=  PurchaseReturn.generate_return_code( item)
      
     
    
    
      new_purchase_return.save 
    
      if not new_purchase_return.valid?
        return new_purchase_return
      end
     
      StockMutation.create_purchase_return(employee,  new_purchase_return ) 
      return new_purchase_return
    end
     
  end
end
