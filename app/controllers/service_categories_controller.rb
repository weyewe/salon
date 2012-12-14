class ServiceCategoriesController < ApplicationController
  def new
    @service_categories = ServiceCategory.active_service_categories 
    @new_service_category = ServiceCategory.new 
    @new_object = @new_service_category
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create
    base_service_category = ServiceCategory.find_by_id params[:service_category][:parent_id]
    
    # sleep 5
    
    @object = base_service_category.create_sub_category( params[:service_category] ) 
    if @object.valid?
      @new_object=  ServiceCategory.new
    else
      @new_object= @object
    end
    
  end
  
  def edit
    @service_category = ServiceCategory.find_by_id params[:id] 
  end
  
  def update_service_category
    @service_category = ServiceCategory.find_by_id params[:service_category_id] 
    @service_category.update_attributes( params[:service_category])
    @has_no_errors  = @service_category.errors.messages.length == 0
  end
  
  def delete_service_category
    @service_category = ServiceCategory.find_by_id params[:object_to_destroy_id]
    @service_category.delete 
  end
end
