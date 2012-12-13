class VendorsController < ApplicationController
 
  def new
    @objects = Vendor.active_vendors
    @new_object = Vendor.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end

  def create
    @object = Vendor.create( params[:vendor] ) 
    if @object.valid?
      @new_object=  Vendor.new
    else
      @new_object= @object
      @objects =  Vendor.active_vendors
    end
    
    respond_to do |format|
      format.html { render :file => 'vendors/new' }
      format.js 
    end
  end

  def search_vendor
    search_params = params[:q]

    @objects = [] 
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = Vendor.where{ (name =~ query)  & (is_deleted.eq false) }.map{|x| {:name => x.name, :id => x.id }}

    respond_to do |format|
      format.html # show.html.erb 
      format.json { render :json => @objects }
    end
  end 
  
  
  def edit
    @vendor = Vendor.find_by_id params[:id] 
  end
  
  def update_vendor
    @vendor = Vendor.find_by_id params[:vendor_id] 
    @vendor.update_attributes( params[:vendor])
    @has_no_errors  = @vendor.errors.messages.length == 0
  end
  
  def delete_vendor
    @vendor = Vendor.find_by_id params[:object_to_destroy_id]
    @vendor.delete 
  end
  
  
end
