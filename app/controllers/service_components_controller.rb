class ServiceComponentsController < ApplicationController
  def new
    @service = Service.find_by_id params[:service_id]
    @objects = @service.active_service_components
    @new_object = ServiceComponent.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create 
    @service = Service.find_by_id params[:service_id]
    @object = @service.add_service_component( params[:service_component] )
    
    if @object.valid?
      @new_object=  ServiceComponent.new
    else
      @new_object= @object
    end 
    
    respond_to do |format|
      format.html { render :file => 'service_components/new' }
      format.js 
    end
  end
 
  
  
   
  def edit
    @service = Service.find_by_id params[:service_id]
    
    @service_component = @service.active_service_components.where(:id => params[:id]).first
  end
  
  def update_service_component
    @service = Service.find_by_id params[:service_id]
    @service_component = @service.active_service_components.where(:id => params[:id]).first
    @service_component.update_attributes( params[:service_component] )
    @has_no_errors  = @service_component.errors.messages.length == 0
  end
  
  def delete_service_component
    @service = Service.find_by_id params[:service_id]
    @service_component = @service.active_service_components.where(:id =>params[:object_to_destroy_id]).first #Service.find_by_id params[:object_to_destroy_id]
    @service_component.delete 
  end
end
