class Service < ActiveRecord::Base
  attr_accessible :name , :number_of_employee, :recommended_selling_price, :commission_per_employee
  has_one :sales_entry, :through => :service_item
  has_one :service_item
  
  validates_presence_of :name 
  
  def set_price(price)
    if price.nil? or price <= BigDecimal('0')
      return nil
    end
    
    self.recommended_selling_price = price
    self.save 
    return self 
  end
  
  def self.active_services
    Service.where(:is_deleted => false).order("created_at DESC")
  end
end
