class PurchaseOrdersController < ApplicationController
  def new
    @new_object = PurchaseOrder.new 
    @pending_confirmation_purchase_orders = PurchaseOrder.where(:is_confirmed => false,
            :is_deleted => false ).order("created_at ASC")
  end
  
  def create
    @vendor = Vendor.find_by_id params[:purchase_order][:vendor_id]
    @new_object = PurchaseOrder.create_purchase_order( current_user, @vendor)
    
    @errors =  @new_object.errors.messages
    
    @has_no_errors  = @errors.length == 0
    
    
    if  @has_no_errors # don't call instance variable .valid? << it will kick out all the errors 
      redirect_to new_purchase_order_purchase_entry_url(@new_object)
      return 
    else
       
      @pending_confirmation_purchase_orders = PurchaseOrder.where(:is_confirmed => false,
              :is_deleted => false ).order("created_at ASC")
      render :file => "purchase_orders/new"
      return 
    end
  end
  
  def confirm_purchase_order 
    @purchase_order = PurchaseOrder.find_by_id params[:purchase_order_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @purchase_order.confirm_purchase( current_user  )
  end
end
