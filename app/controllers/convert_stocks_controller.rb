class ConvertStocksController < ApplicationController
  def new
    @objects = StockConversion.active_stock_conversions
    @new_object = ConvertStock.new
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js  do
        @stock_conversion = StockConversion.find_by_id params[:stock_conversion_id]
      end
    end
  end
  
  def create 
    @stock_conversion = StockConversion.find_by_id params[:stock_conversion_id] 
    ActiveRecord::Base.transaction do 
      @object = @stock_conversion.execute_convert_stock_one_on_one( current_user, params[:convert_stock][:source_quantity].to_i)
    end
    
    @has_no_errors  = @object.errors.messages.length == 0
    if @has_no_errors
      @new_object=  ConvertStock.new
    else
      @new_object= @object 
    end 
    
    respond_to do |format|
      format.html do
        @objects =  StockConversion.active_stock_conversions
        render :file => 'stock_conversions/new' 
      end
         
      format.js do
      end
    end
  end
end
