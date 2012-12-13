class StockMigrationsController < ApplicationController
  def new
    @new_object = StockMigration.new 
  end
  
  # only the view 
  def generate_stock_migration
    @new_object = StockEntry.new 
    @item_id =  params[:selected_item_id] 
    @item = Item.find_by_id @item_id
  end
  
  def create 
    @item = Item.find_by_id params[:item_id]  
    quantity = params[:stock_entry][:quantity].to_i 
    price_per_item = BigDecimal( params[:stock_entry][:base_price_per_piece] ) 
    
    # @object = StockMigration.create_item_migration(current_user , item, params[:stock_migration])
    @object =   StockMigration.create_item_migration(current_user , @item, quantity,  price_per_item)  
    @item.reload 
    
    
    if @object.valid?
      @new_object=  StockMigration.new 
    else
      @new_object= @object
    end 
  end
  
  
  
end
