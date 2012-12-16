class Category < ActiveRecord::Base
  attr_accessible :name, :parent_id
  acts_as_nested_set
  
  has_many :items 
  
  validates_presence_of :name
  validate :unique_non_deleted_name 
  
  def unique_non_deleted_name
    current_service = self
     
     # claim.status_changed?
    if not current_service.name.nil? 
      if not current_service.persisted? and current_service.has_duplicate_entry?  
        errors.add(:name , "Sudah ada category  dengan nama sejenis" )  
      elsif current_service.persisted? and 
            current_service.name_changed?  and
            current_service.has_duplicate_entry?   
            # if duplicate entry is itself.. no error
            # else.. some error
            
          if current_service.duplicate_entries.count ==1  and 
              current_service.duplicate_entries.first.id == current_service.id 
          else
            errors.add(:name , "Sudah ada category  dengan nama sejenis" )  
          end 
      end
    end
  end
  
  def has_duplicate_entry?
    current_service=  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted   ', 
                {:name => current_service.name.downcase, :is_deleted => false  }]).count != 0  
  end
  
  def duplicate_entries
    current_service=  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  ', 
                {:name => current_service.name.downcase, :is_deleted => false }]) 
  end
  
  def create_sub_category( category_params ) 
    new_category = Category.create(:name => category_params[:name],
                              :parent_id => self.id ) 
    return new_category
  end
  
  
  def self.all_selectable_categories
    categories  = Category.where(:is_deleted => false ) .order("depth  ASC ")
    result = []
    categories.each do |category| 
      result << [ "#{category.name}" , 
                      category.id ]  
    end
    return result
  end
  
  def self.active_categories
    Category.where(:is_deleted => false).order("created_at DESC")
  end
  
  def delete
    parent = self.parent 
    if parent.nil?
      # can't be deleted from the base
      return nil
    end
    
    self.is_deleted = true
    self.save
    
    self.items.each do |item|
      item.category_id = parent.id
      item.save 
    end
    # what will happen to the item from this category? Go to the parent category 
  end
  
  
end
