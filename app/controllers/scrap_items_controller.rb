class ScrapItemsController < ApplicationController
  

  def new
    @new_object = ScrapItem.new 
  end

  # only the view 
  def generate_scrap_item
    @new_object = ScrapItem.new 
    @item_id =  params[:selected_item_id] 
    @item = Item.find_by_id @item_id
  end

  def create 
    @item = Item.find_by_id params[:item_id]  
    quantity = params[:scrap_item][:quantity].to_i  

    # @object = StockMigration.create_item_migration(current_user , item, params[:stock_migration])
    @scrap_item =   ScrapItem.create_scrap( current_user, @item, quantity)  
    @object = @scrap_item  
    @item.reload 


    if @object.valid?
      @new_object=  ScrapItem.new 
    else
      @new_object= @object
    end

  end 

  
  
end
