class ServiceComponent < ActiveRecord::Base
  attr_accessible :name
  belongs_to :service 
  has_many :items, :through => :compatibilities
  has_many :compatibilities 
  validates_presence_of :name 
  
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service_component = self
     
    if not current_service_component.name.nil? and  
        current_service_component.has_duplicate_entry?    
      if not current_service_component.persisted?
        errors.add(:name , "Sudah ada service component dengan nama sejenis" )  
      elsif current_service_component.persisted? and current_service_component.name_changed?  
        errors.add(:name , "Sudah ada service component dengan nama sejenis" )  
      end
    end
    
    
  end
  
  def has_duplicate_entry?
    current_service_component  = self  
    ServiceComponent.find(:all, :conditions => 
                ['lower(name) = :name and is_deleted = :is_deleted  and service_id = :service_id', 
                {:name => current_service_component.name.downcase, :is_deleted => false , 
                  :service_id => current_service_component.service_id}]).count != 0  
  end
  
  def ServiceComponent.active_components(service) 
    self.where(:is_deleted => false, :service_id => service.id ).order("created_at DESC")
  end
  
  
  def delete
    self.is_deleted = true 
    self.save 
  end
  
end
