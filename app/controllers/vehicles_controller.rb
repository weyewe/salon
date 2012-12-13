class VehiclesController < ApplicationController
  
  def new
    @objects = Vehicle.active_vehicles
    @new_object = Vehicle.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js  
    end
  end
  
  def new_vehicle_from_sales_order
    @objects = Vehicle.active_vehicles
    @new_object = Vehicle.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js  
    end
  end

  def create
    id_code = params[:vehicle][:id_code] 
    params[:vehicle][:id_code]  =  id_code.upcase.gsub(/\s+/, "")
    
    
    @object = Vehicle.create( params[:vehicle] ) 
    if @object.valid?
      @new_object=  Vehicle.new
    else
      @new_object= @object
      @objects =  Vehicle.active_vehicles
    end
    
    respond_to do |format|
      format.html { render :file => 'vehicles/new' }
      format.js do
        @customer = Customer.find_by_id params[:vehicle][:customer_id]
      end
    end
  end
  
  
  def create_vehicle_from_sales_order
    
    id_code = params[:vehicle][:id_code] 
    params[:vehicle][:id_code]  =  id_code.upcase.gsub(/\s+/, "")
    
    
    @object = Vehicle.create( params[:vehicle] ) 
    if @object.valid?
      @new_object=  Vehicle.new
    else
      @new_object= @object 
    end
    
    respond_to do |format| 
      format.js do
        @customer = Customer.find_by_id params[:vehicle][:customer_id]
      end
    end
  end

  def search_vehicle
    search_params = params[:q]
    if search_params.nil?
      return nil
    else
      search_params= search_params.upcase.gsub(/\s+/, "") 
    end
    
    @vehicles = [] 
    item_query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @vehicles = Vehicle.where{ (id_code =~ item_query) & (is_deleted.eq false)  }.map{|x| {:name => x.id_code, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vehicles }
      format.json { render :json => @vehicles }
    end
  end
  
  
  def edit
    @vehicle = Vehicle.find_by_id params[:id] 
  end
  
  def update_vehicle
    @vehicle = Vehicle.find_by_id params[:vehicle_id] 
    @vehicle.update_attributes( params[:vehicle])
    @has_no_errors  = @vehicle.errors.messages.length == 0
  end
  
  def delete_vehicle
    @vehicle = Vehicle.find_by_id params[:object_to_destroy_id]
    @vehicle.delete 
  end
  
  
  
  
  
end
