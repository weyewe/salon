class CompatibilitiesController < ApplicationController
  def new
    @service_component = ServiceComponent.find_by_id params[:service_component_id]
    @objects = @service_component.active_compatibilities 
    @new_object = Compatibility.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create 
    @service_component = ServiceComponent.find_by_id params[:service_component_id]
    @object = @service_component.add_compatibility( params[:compatibility] )
    
    if @object.valid?
      @new_object=  Compatibility.new
    else
      @new_object= @object
    end 
    
    respond_to do |format|
      format.html { render :file => 'compatibilities/new' }
      format.js 
    end
  end
 
  
  
   
  def edit
    @service_component = ServiceComponent.find_by_id params[:service_component_id]
    
    @compatibility = @service_component.active_compatibilities.where(:id => params[:id]).first
    @new_object = @compatibility
  end
  
  def update_compatibility
    @service_component = ServiceComponent.find_by_id params[:service_component_id]
    @compatibility = @service_component.active_compatibilities.where(:id => params[:id]).first
    @compatibility.update_attributes( params[:compatibility] )
    @has_no_errors  = @compatibility.errors.messages.length == 0
  end
  
  def delete_compatibility
    @service_component = ServiceComponent.find_by_id params[:service_component_id]
    @compatibility = @service_component.active_compatibilities.where(:id =>params[:object_to_destroy_id]).first #Service.find_by_id params[:object_to_destroy_id]
    @compatibility.delete 
  end
end
