class PurchaseEntriesController < ApplicationController
  def new
    @purchase_order = PurchaseOrder.find_by_id params[:purchase_order_id]
    
    add_breadcrumb "Create Invoice", 'new_purchase_order_url'
    set_breadcrumb_for @group_loan, 'new_purchase_order_purchase_entry_url' + "(#{@purchase_order.id})", 
                "#{@purchase_order.code}"
  end
  
  def generate_purchase_entry_add_product_form
    @item=  Item.find_by_id params[:selected_item_id]
    @purchase_order = PurchaseOrder.find_by_id params[:purchase_order_id]
    @new_object = PurchaseEntry.new
  end
  
  def create
    @purchase_order = PurchaseOrder.find_by_id params[:purchase_order_id]
    @item = Item.find_by_id params[:item_id]
    @quantity = params[:purchase_entry][:quantity].to_i
    @price_per_piece =  BigDecimal( params[:purchase_entry][:price_per_piece] )
    
    @has_past_item =  @purchase_order.has_purchase_entry_for_item?(@item) 
    
    
    @purchase_entry =   @purchase_order.add_purchase_entry_item( @item,    
                                                        @quantity, 
                                                        @price_per_piece )
                          
    @has_no_errors  = @purchase_entry.errors.messages.length == 0  
  end
  
  def edit
    @purchase_order = PurchaseOrder.find_by_id params[:purchase_order_id]
    @purchase_entry =  @purchase_order.active_purchase_entries.where(:id => params[:id]).first
    @item = @purchase_entry.item 
  end
  
  def update_purchase_entry
    @purchase_order = PurchaseOrder.find_by_id params[:purchase_order_id]
    @purchase_entry =  @purchase_order.active_purchase_entries.where(:id => params[:id]).first
    
    @quantity =  params[:purchase_entry][:quantity].to_i
    @price_per_piece =  BigDecimal( params[:purchase_entry][:price_per_piece] )
    
    @new_object = @purchase_entry.update_item( @quantity, @price_per_piece)
    @has_no_errors  = @new_object.errors.messages.length == 0  
    
    @item = @purchase_entry.item
  end
  
  def delete_purchase_entry_from_purchase_order
    @purchase_order = PurchaseOrder.find_by_id params[:purchase_order_id]
    @purchase_entry = @purchase_order.active_purchase_entries.where(:id => params[:object_to_destroy_id]).first
    @purchase_order.delete_purchase_entry( @purchase_entry )
  end
  
end
