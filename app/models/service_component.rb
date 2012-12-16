class ServiceComponent < ActiveRecord::Base
  attr_accessible :name
  belongs_to :service 
  has_many :items, :through => :compatibilities
  has_many :compatibilities 
  validates_presence_of :name 
  has_many :service_usages
  
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service = self
     
     # claim.status_changed?
    if not current_service.name.nil? 
      if not current_service.persisted? and current_service.has_duplicate_entry?  
        errors.add(:name , "Sudah ada service component dengan nama sejenis" )  
      elsif current_service.persisted? and 
            current_service.name_changed?  and
            current_service.has_duplicate_entry?   
            # if duplicate entry is itself.. no error
            # else.. some error
            
          if current_service.duplicate_entries.count ==1  and 
              current_service.duplicate_entries.first.id == current_service.id 
          else
            errors.add(:name , "Sudah ada service  component dengan nama sejenis" )  
          end 
      end
    end
  end
  
  def has_duplicate_entry?
    current_service=  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  and service_id = :service_id', 
                {:name => current_service.name.downcase, :is_deleted => false, 
                    :service_id => current_service.service_id }]).count != 0  
  end
  
  def duplicate_entries
    current_service=  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  and service_id = :service_id', 
                {:name => current_service.name.downcase, :is_deleted => false, 
                    :service_id => current_service.service_id }]) 
  end
  
  def ServiceComponent.active_components(service) 
    self.where(:is_deleted => false, :service_id => service.id ).order("created_at DESC")
  end
  
  
  def delete
    self.is_deleted = true 
    self.save 
    
    #  find the service usage 
    self.unconfirmed_service_usage.each do |service_usage|
      service_usage.destroy 
    end
  end
  
  def unconfirmed_service_usage
    
    # self.service_usages.where(:service_item => {:sales_entry => {:sales_order => {:is_confirmed => false }} })
    
    self.service_usages.where(:sales_order => {:is_confirmed => false })
  end
  
=begin
  COMPATIBILITY
=end
  def active_compatibilities
    self.compatibilities.where(:is_deleted => false).order("created_at DESC")
  end
  
  def add_compatibility( compatibility_params)
    new_compatibility = Compatibility.new
    new_compatibility.quantity  = compatibility_params[:quantity]
    new_compatibility.item_id  = compatibility_params[:item_id]
    new_compatibility.service_component_id = self.id 
    
    new_compatibility.save
    return new_compatibility
  end
  
=begin
  SALON specific
=end

  def first_available_compatibility
    self.active_compatibilities.first 
  end
   
end
