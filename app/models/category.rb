class Category < ActiveRecord::Base
  attr_accessible :name, :parent_id
  acts_as_nested_set
  
  has_many :items 
  
  validates_presence_of :name
  validates_uniqueness_of :name 
  
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
