class PurchaseReturnsController < ApplicationController
  def new
    @new_object = PurchaseReturn.new 
  end

  # only the view 
  def generate_purchase_return
    @new_object = PurchaseReturn.new 
    @item_id =  params[:selected_item_id] 
    @item = Item.find_by_id @item_id
  end

  def create 
    @item = Item.find_by_id params[:item_id]  
    quantity = params[:purchase_return][:quantity].to_i  

    # @object = StockMigration.create_item_migration(current_user , item, params[:stock_migration])
    @purchase_return =   PurchaseReturn.create_item_return( current_user, @item, quantity)  
    @object = @purchase_return  
    @item.reload 


    if @object.valid?
      @new_object=  PurchaseReturn.new 
    else
      @new_object= @object
    end

  end
end
