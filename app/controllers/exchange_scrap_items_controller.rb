class ExchangeScrapItemsController < ApplicationController
  def new
    @new_object = ExchangeScrapItem.new 
  end

  # only the view 
  def generate_exchange_scrap_item
    @new_object = ExchangeScrapItem.new 
    @item_id =  params[:selected_item_id] 
    @item = Item.find_by_id @item_id
  end

  def create 
    @item = Item.find_by_id params[:item_id]  
    quantity = params[:exchange_scrap_item][:quantity].to_i  

# create_exchange_scrap( employee, item, quantity) 
    # @object = StockMigration.create_item_migration(current_user , item, params[:stock_migration])
    @scrap_item =   ExchangeScrapItem.create_exchange_scrap( current_user, @item, quantity)  
    @object = @scrap_item  
    @item.reload 


    if @object.valid?
      @new_object=  ExchangeScrapItem.new 
    else
      @new_object= @object
    end

  end
end
