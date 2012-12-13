class StockConversionsController < ApplicationController
  def new
    @objects = StockConversion.active_stock_conversions
    @new_object = StockConversion.new
  end
  
  def create
    @source_item = Item.find_by_id params[:stock_conversion][:source_item_id]
    @target_item = Item.find_by_id params[:stock_conversion][:target_item_id]
    @quantity =  params[:stock_conversion][:target_quantity].to_i
    
    ActiveRecord::Base.transaction do 
      @object = StockConversion.create_one_to_one( current_user, @source_item, @target_item, @quantity ) 
    end
    
    
    
    
    
    @has_no_errors  = @object.errors.messages.length == 0
    if @has_no_errors
      @new_object=  StockConversion.new
    else
      @new_object= @object 
    end
    
    
    
    respond_to do |format|
      format.html do
        @objects =  StockConversion.active_stock_conversions
        render :file => 'stock_conversions/new' 
      end
         
      format.js 
    end
  end
  
  def edit
    # if there is  mutation executed, we can't edit the stock conversion 
    # solution? create the new one. 
  end
end
