class ServiceCategory < ActiveRecord::Base 
  has_many :services
  attr_accessible :name, :parent_id
  acts_as_nested_set
  
  validates_presence_of :name
  # validates_uniqueness_of :name,   :case_sensitive => false , :if => :no_other_active_entry #, :scope => { }
  # validate :uniqueness_of_name_if_not_deleted
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service = self
     
     # claim.status_changed?
    if not current_service.name.nil? 
      if not current_service.persisted? and current_service.has_duplicate_entry?  
        errors.add(:name , "Sudah ada service category dengan nama sejenis" )  
      elsif current_service.persisted? and 
            current_service.name_changed?  and
            current_service.has_duplicate_entry?  
        # this is on update
        errors.add(:name , "Sudah ada service category dengan nama sejenis" )  
      end
    end
  end
  
  def has_duplicate_entry?
    current_service=  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  ', 
                {:name => current_service.name.downcase, :is_deleted => false }]).count != 0  
  end
  
  def duplicate_entries
    current_service=  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted   ', 
                {:name => current_service.name.downcase, :is_deleted => false  }]) 
  end
   
  
  def self.active_service_categories
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def create_sub_category( service_category_params ) 
    new_category = ServiceCategory.new  
    new_category.name = service_category_params[:name]
    new_category.parent_id = self.id 
    
    if new_category.valid?
      new_category.save 
    end
    return new_category
  end
  
  def self.all_selectable_service_categories
    categories  = ServiceCategory.where(:is_deleted => false ).order("depth  ASC ")
    result = []
    categories.each do |category| 
      result << [ "#{category.name}" , 
                      category.id ]  
    end
    return result
  end
  
  def delete
    parent = self.parent 
    if parent.nil?
      # can't be deleted from the base
      return nil
    end
    
    self.is_deleted = true
    self.save
    
    self.services.each do |service|
      service.service_category_id = parent.id
      service.save 
    end
    # what will happen to the item from this category? Go to the parent category 
  end
end
