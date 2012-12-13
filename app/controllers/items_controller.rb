class ItemsController < ApplicationController
  def new
    @objects = Item.active_items
    @new_object = Item.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create 
    @category = Category.find_by_id params[:item][:category_id]
    
    @object = Item.create_by_category(  @category, params[:item])
    
    
    if @object.valid?
      @new_object=  Item.new
    else
      @new_object= @object
    end 
    
    respond_to do |format|
      format.html { render :file => 'items/new' }
      format.js 
    end
    
  end
  
  def search_item
    
    # verify the current_user 
    search_params = params[:q]
    
    @items = [] 
    item_query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @items = Item.where{ (name =~ item_query)  }.map{|x| {:name => x.name, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @items }
    end 
  end
  
  def search_sales_order_item
    search_params = params[:q]
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    # @objects = Item.where(
    #              :id => @sales_order.item_id_list ,
    #              :is_deleted => false 
    #            ).map{|x| {:name => x.name, :id => x.id }}
    #          
    item_id_list =    @sales_order.item_id_list 
    @objects = Item.where{
          ( is_deleted.eq false) & 
          (id.in item_id_list ) & 
          (name =~ query) 
    }.map{|x| {:name => x.name, :id => x.id }} 
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @objects }
    end
    
  end
  
  
  def edit
    @item = Item.find_by_id params[:id] 
  end
  
  def update_item
    @item = Item.find_by_id params[:item_id] 
    @item.update_attributes( params[:item])
    @has_no_errors  = @item.errors.messages.length == 0
  end
  
  def delete_item
    @item = Item.find_by_id params[:object_to_destroy_id]
    @item.delete 
  end
  
  
  
end
