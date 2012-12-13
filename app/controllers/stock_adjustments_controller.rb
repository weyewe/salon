class StockAdjustmentsController < ApplicationController

  def new
    @new_object = StockAdjustment.new 
  end

  # only the view 
  def generate_stock_adjustment
    @new_object = StockAdjustment.new 
    @item_id =  params[:selected_item_id] 
    @item = Item.find_by_id @item_id
  end

  def create 
    @item = Item.find_by_id params[:item_id]  
    physical_quantity = params[:stock_adjustment][:physical_quantity].to_i  

    # @object = StockMigration.create_item_migration(current_user , item, params[:stock_migration])
    @stock_adjustment =   StockAdjustment.create_item_adjustment(current_user , @item, physical_quantity )  
    @object = @stock_adjustment  
    @item.reload 

    
    if @object.valid?
      @new_object=  StockAdjustment.new 
    else
      @new_object= @object
    end
     
  end 
end
