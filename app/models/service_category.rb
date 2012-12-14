class ServiceCategory < ActiveRecord::Base 
  has_many :services
  attr_accessible :name, :parent_id
  acts_as_nested_set
  
  validates_presence_of :name
  # validates_uniqueness_of :name,   :case_sensitive => false , :if => :no_other_active_entry #, :scope => { }
  # validate :uniqueness_of_name_if_not_deleted
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service_category = self
     
    if not current_service_category.name.nil? and  
        current_service_category.has_duplicate_entry?   and not current_service_category.persisted?
      puts "~~~~~~~~~~~~~~~~THIS IS A CALL FROM UNIQUE NON DELETED NAME\n"*5 
      errors.add(:name , "Sudah ada service dengan nama sejenis" )  
    end
  end
  
  def has_duplicate_entry?
    current_service_category=  self 
    # ServiceCategory.exists?(['lower(name) = ? and is_deleted = ? ', current_service_category.name.downcase , false]) and
    # ServiceCategory.where(:name => current_service_category.name , :is_deleted => false).count > 0
    ServiceCategory.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted ', 
                {:name => current_service_category.name.downcase, :is_deleted => false }]).count != 0 
    
    # Model.find(:all,:conditions=>["created > :start_date and created < :end_date", 
    #         {:start_date => params[:one], :end_date => params[:two]}])
    # 
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
