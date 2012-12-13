class CategoriesController < ApplicationController
  def new
    @categories = Category.active_categories 
    @new_category = Category.new 
    @new_object = @new_category
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create
    base_category = Category.find_by_id params[:category][:parent_id]
    
    # sleep 5
    
    @object = base_category.create_sub_category( params[:category] ) 
    if @object.valid?
      @new_object=  Category.new
    else
      @new_object= @object
    end
    
  end
  
  def edit
    @category = Category.find_by_id params[:id] 
  end
  
  def update_category
    @category = Category.find_by_id params[:category_id] 
    @category.update_attributes( params[:category])
    @has_no_errors  = @category.errors.messages.length == 0
  end
  
  def delete_category
    @category = Category.find_by_id params[:object_to_destroy_id]
    @category.delete 
  end
  
end
