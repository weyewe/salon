class Service < ActiveRecord::Base
  attr_accessible :name , :number_of_employee, :recommended_selling_price, :commission_per_employee
  has_one :sales_entry, :through => :service_item
  has_one :service_item
  
  belongs_to :service_category 
  has_many :service_components
  
  validates_presence_of :name 
  
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service_category = self
     
    if not current_service_category.name.nil? and  
        current_service_category.has_duplicate_entry?   and not current_service_category.persisted?
      errors.add(:name , "Sudah ada service dengan nama sejenis" )  
    end
  end
  
  def has_duplicate_entry?
    current_service_category=  self  
    Service.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted ', 
                {:name => current_service_category.name.downcase, :is_deleted => false }]).count != 0  
  end
  
  
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
  
=begin
  SErVICE COMPONENT RELATED
=end
  def active_service_components
    self.service_components.where(:is_deleted => false).order("created_at DESC")
  end
  
  def add_service_component( service_component_params)
    new_service_component = ServiceComponent.new
    new_service_component.name  = service_component_params[:name]
    new_service_component.service_id = self.id 
    
    new_service_component.save
    return new_service_component
  end
end
