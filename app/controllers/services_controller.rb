class ServicesController < ApplicationController
  def new
    @objects = Service.active_services
    @new_object = Service.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create 
    @object = Service.create( params[:service])
    
    if @object.valid?
      @new_object=  Service.new
    else
      @new_object= @object
    end 
    
    respond_to do |format|
      format.html { render :file => 'services/new' }
      format.js 
    end
  end
  
  def search_service
    # verify the current_user 
    search_params = params[:q]
    
    @services = [] 
    service_query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @services = Service.where{ (name =~ service_query)  }.map{|x| {:name => x.name, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @services }
    end
  end
  
  
   
  def edit
    @service = Service.find_by_id params[:id] 
  end
  
  def update_service
    @service = Service.find_by_id params[:service_id] 
    @service.update_attributes( params[:service] )
    @has_no_errors  = @service.errors.messages.length == 0
  end
  
  def delete_service
    @service = Service.find_by_id params[:object_to_destroy_id]
    @service.delete 
  end
  
  
end
