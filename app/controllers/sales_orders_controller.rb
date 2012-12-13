class SalesOrdersController < ApplicationController
  
  def new
    @new_object = SalesOrder.new 
    @pending_confirmation_sales_orders = SalesOrder.where(:is_confirmed => false, :is_deleted => false ).order("created_at DESC")
    @confirmed_sales_orders = SalesOrder.where(:is_confirmed => true, :is_deleted => false ).order("confirmed_datetime DESC").limit(10)
  end
  
  
  
  
  def create
    @vehicle = Vehicle.find_by_id params[:sales_order][:vehicle_id]
    @customer = Customer.find_by_id params[:sales_order][:customer_id]
    @new_object = SalesOrder.create_sales_order( current_user, @customer  )
    
    @errors =  @new_object.errors.messages
    
    @errors.each do |error|
      error.each do |x|
        puts x
      end
    end
    
     
    @has_no_errors  = @errors.length == 0
     
    if  @has_no_errors  
      redirect_to new_sales_order_sales_entry_url(@new_object)
      return 
    else 
      @pending_confirmation_sales_orders = SalesOrder.where(:is_confirmed => false, :is_deleted => false ).order("created_at ASC")
      render :file => "sales_orders/new"
      return 
    end
  end
   
  def search_sales_order
    
    # verify the current_user 
    search_params = params[:q]
    
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @objects = SalesOrder.where{ (code =~ query) & 
                  (is_confirmed.eq true) & 
                  (is_deleted.eq false)  }.map{|x| {:name => x.code, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @objects }
    end 
  end
  
  
  
  def confirm_sales_order
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @sales_order.confirm_sales( current_user  )  
  end
  
  def delete_sales_order 
    redirect_to new_sales_order_url 
  end
  
  
  def print_sales_invoice
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    respond_to do |format|
      format.html # do
       #        pdf = SalesInvoicePdf.new(@sales_order, view_context)
       #        send_data pdf.render, filename:
       #        "#{@sales_order.printed_sales_invoice_code}.pdf",
       #        type: "application/pdf"
       #      end
      format.pdf do
        pdf = SalesInvoicePdf.new(@sales_order, view_context,CONTINUOUS_FORM_WIDTH,FULL_CONTINUOUS_FORM_LENGTH)
        send_data pdf.render, filename:
        "#{@sales_order.printed_sales_invoice_code}.pdf",
        type: "application/pdf"
      end
    end
  end
  
  def generate_form_to_edit_sales_order_customer
    @sales_order = SalesOrder.find_by_id  params[:sales_order_id]
    @customer= @sales_order.customer 
  end
  
  def update_sales_order_customer
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    @customer = SalesOrder.find_by_id params[:sales_order][:customer_id]
    @sales_order.update_customer( @customer ) 
  end
   
  
end
