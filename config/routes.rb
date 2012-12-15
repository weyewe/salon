Salmod::Application.routes.draw do
  devise_for :users
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end

  root :to => 'home#index'
  root :to => 'home#login'
  
  resources :companies
  match 'update_company/:id' => 'companies#update_company', :as => :update_company, :method => :post 
  
  
  resources :categories 
  resources :items 
  
  match 'search_item'  => 'items#search_item' , :as => :search_item
  match 'search_service' => 'services#search_service', :as => :search_service
  
  
  resources :stock_migrations 
  match 'generate_stock_migration'  => 'stock_migrations#generate_stock_migration' , :as => :generate_stock_migration, :method => :post 
  
  
  resources :stock_adjustments
  match 'generate_stock_adjustment'  => 'stock_adjustments#generate_stock_adjustment' , :as => :generate_stock_adjustment, :method => :post 
  
  resources :scrap_items
  match 'generate_scrap_item'  => 'scrap_items#generate_scrap_item' , :as => :generate_scrap_item, :method => :post 
  
  resources :exchange_scrap_items
  match 'generate_exchange_scrap_item'  => 'exchange_scrap_items#generate_exchange_scrap_item' , :as => :generate_exchange_scrap_item, :method => :post
  
  
  resources :purchase_returns
  match 'generate_purchase_return'  => 'purchase_returns#generate_purchase_return' , :as => :generate_purchase_return, :method => :post
  
  
  
=begin
  SERVICE RELATED
=end

  resources :service_categories do
    resources :services 
  end
  
  resources :services do
    resources :service_components 
  end
=begin
  Creating Sales Order
=end
  resources :customers 
  resources :sales_orders do
    resources :sales_entries 
  end
  resources :purchase_orders do
    resources :purchase_entries  
  end
  
  resources :sales_returns do 
    resources :sales_return_entries
  end
  
  # employee management 
  resources :employees
  resources :vendors 
  resources :services
  resources :vehicles
  
  resources :stock_conversions do
    resources :conversion_entries 
    resources :convert_stocks
  end
  
  resources :convert_stocks
  
   

  match 'generate_sales_order'  => 'sales_orders#generate_sales_order' , :as => :generate_sales_order, :method => :post 
  match 'search_vehicle'  => 'vehicles#search_vehicle' , :as => :search_vehicle
  match 'search_customer' => "customers#search_customer", :as => :search_customer 
  match 'search_vendor' => "vendors#search_vendor", :as => :search_vendor 
  match 'search_sales_order' => "sales_orders#search_sales_order", :as => :search_sales_order 
  
  match 'search_sales_order_item/:sales_order_id' => 'items#search_sales_order_item', :as => :search_sales_order_item
  
 
  
=begin
  Edit sales order's customer
=end
  match 'generate_form_to_edit_sales_order_customer/:sales_order_id' => 'sales_orders#generate_form_to_edit_sales_order_customer', :as => :generate_form_to_edit_sales_order_customer
  match 'update_sales_order_customer/:sales_order_id' => 'sales_orders#update_sales_order_customer', :as => :update_sales_order_customer, :method => :post

=begin
  Create new vehicle from sales order
=end
  match 'new_vehicle_from_sales_order' => 'vehicles#new_vehicle_from_sales_order', :as => :new_vehicle_from_sales_order  
  match 'create_vehicle_from_sales_order' => 'vehicles#create_vehicle_from_sales_order', :as => :create_vehicle_from_sales_order, :method => :post 

=begin
  Adding Sales Entry
=end
  match 'generate_sales_entry_add_product_form' => 'sales_entries#generate_sales_entry_add_product_form', :as => :generate_sales_entry_add_product_form, :method => :post 
  match 'generate_sales_entry_add_service_form' => 'sales_entries#generate_sales_entry_add_service_form', :as => :generate_sales_entry_add_service_form, :method => :post 
  
  match 'create_service_sales_entry/:sales_order_id' => 'sales_entries#create_service_sales_entry', :as => :create_service_sales_entry , :method => :post 

=begin
  Editing sales entry 
=end
  match 'update_sales_entry/:sales_order_id/sales_entry/:id' => 'sales_entries#update_sales_entry', :as => :update_sales_entry, :method => :post 
  match 'update_sales_entry_service/:sales_order_id/sales_entry/:id' => 'sales_entries#update_sales_entry_service', :as => :update_sales_entry_service, :method => :post 
  
   
=begin
  DELETE Sales Entry
=end
  match 'delete_sales_entry_from_sales_order/:sales_order_id' => 'sales_entries#delete_sales_entry_from_sales_order', :as => :delete_sales_entry_from_sales_order, :method => :post 


=begin
  CONFIRM SALES ORDER 
=end
  match 'confirm_sales_order/:sales_order_id' => "sales_orders#confirm_sales_order", :as => :confirm_sales_order, :method => :post 
  match 'delete_sales_order/:sales_order_id' => "sales_orders#delete_sales_order", :as => :delete_sales_order, :method => :post 
  
=begin
  Special for Service: add vehicle and items 
=end
  match 'generate_form_to_add_service_sales_entry_details/:sales_entry_id' => 'sales_entries#generate_form_to_add_service_sales_entry_details', :as => :generate_form_to_add_service_sales_entry_details
  match 'create_service_sales_entry_details/:sales_entry_id' => 'sales_entries#create_service_sales_entry_details', :as => :create_service_sales_entry_details, :method => :post 

=begin
  Printing Sales Invoice
=end
  match 'print_sales_invoice/:sales_order_id' => 'sales_orders#print_sales_invoice', :as => :print_sales_invoice
##################################################
##################################################
######### Create PURCHASE ORDER + ENTRIES 
##################################################
##################################################


=begin
  Adding Purchase Entry
=end
  match 'generate_purchase_entry_add_product_form' => 'purchase_entries#generate_purchase_entry_add_product_form', :as => :generate_purchase_entry_add_product_form, :method => :post 
 

=begin
  Editing Purchase Entry
=end
  match 'update_purchase_entry/:purchase_order_id/purchase_entry/:id' => 'purchase_entries#update_purchase_entry', :as => :update_purchase_entry, :method => :post

=begin
  DELETE PurchaseEntry
=end
  match 'delete_purchase_entry_from_purchase_order/:purchase_order_id' => 'purchase_entries#delete_purchase_entry_from_purchase_order', :as => :delete_purchase_entry_from_purchase_order, :method => :post 


=begin
  CONFIRM  PURCHASE ORDER
=end
  match 'confirm_purchase_order/:purchase_order_id' => "purchase_orders#confirm_purchase_order", :as => :confirm_purchase_order, :method => :post 
  match 'delete_purchase_order/:purchase_order_id' => "purchase_orders#delete_purchase_order", :as => :delete_purchase_order, :method => :post 

##################################################
##################################################
######### Create SALES_RETURN + ENTRIES 
##################################################
##################################################


=begin
  Adding Sales Return Entry
=end
  match 'generate_sales_return_entry_add_product_form' => 'sales_return_entries#generate_sales_return_entry_add_product_form', :as => :generate_sales_return_entry_add_product_form, :method => :post 


=begin
  Editing Sales Return Entry
=end
  match 'update_sales_return_entry/:sales_return_id/sales_return_entry/:id' => 'sales_return_entries#update_sales_return_entry', :as => :update_sales_return_entry, :method => :post

=begin
  DELETE Sales Return Entry
=end
  match 'delete_sales_return_entry_from_sales_return/:sales_return_id' => 'sales_return_entries#delete_sales_return_entry_from_sales_return', :as => :delete_sales_return_entry_from_sales_return, :method => :post 


=begin
  CONFIRM  Sales Return 
=end
  match 'confirm_sales_return/:sales_return_id' => "sales_returns#confirm_sales_return", :as => :confirm_sales_return, :method => :post 
  match 'delete_sales_return/:sales_return_id' => "sales_returns#delete_sales_return", :as => :delete_sales_return, :method => :post


=begin
  Printing Sales Invoice
=end
  match 'print_sales_return/:sales_return_id' => 'sales_returns#print_sales_return', :as => :print_sales_return
  
####################################################################################################
####################################################################################################
############################ =>         Master Data                    #############################
####################################################################################################
#################################################################################################### 
   
##################################################
##################################################
######### EMPLOYEE PERFORMANCE THROUGH SERVICE ITEMS    + EMPLOYEE
##################################################
##################################################
  match 'service_done_by_employee/:employee_id' => 'service_items#service_done_by_employee', :as => :service_done_by_employee
  match 'update_employee/:employee_id' => 'employees#update_employee', :as => :update_employee , :method => :post 
  match 'delete_employee' => 'employees#delete_employee', :as => :delete_employee , :method => :post 
   
##################################################
##################################################
######### VENDOR
##################################################
##################################################
  match 'update_vendor/:vendor_id' => 'vendors#update_vendor', :as => :update_vendor , :method => :post 
  match 'delete_vendor' => 'vendors#delete_vendor', :as => :delete_vendor , :method => :post 
  
##################################################
##################################################
######### CATEGORY
##################################################
##################################################
  match 'update_category/:category_id' => 'categories#update_category', :as => :update_category , :method => :post 
  match 'delete_category' => 'categories#delete_category', :as => :delete_category , :method => :post
  
##################################################
##################################################
######### Service CATEGORY
##################################################
##################################################
  match 'update_service_category/:service_category_id' => 'service_categories#update_service_category', :as => :update_service_category , :method => :post 
  match 'delete_service_category' => 'service_categories#delete_service_category', :as => :delete_service_category , :method => :post
  
##################################################
##################################################
######### Service COMPONENT
##################################################
##################################################
  match 'update_service_component/:service_id/service_component/:id' => 'service_components#update_service_component', :as => :update_service_component , :method => :post 
  match 'delete_service_component/:service_id' => 'service_components#delete_service_component', :as => :delete_service_component , :method => :post


  
##################################################
##################################################
######### ITEM
##################################################
##################################################
  match 'update_item/:item_id' => 'items#update_item', :as => :update_item , :method => :post 
  match 'delete_item' => 'items#delete_item', :as => :delete_item , :method => :post
  
##################################################
##################################################
######### SERVICE
##################################################
##################################################
  match 'update_service/:service_id' => 'services#update_service', :as => :update_service , :method => :post 
  match 'delete_service' => 'services#delete_service', :as => :delete_service , :method => :post
  
##################################################
##################################################
######### CUSTOMER
##################################################
##################################################
  match 'update_customer/:customer_id' => 'customers#update_customer', :as => :update_customer , :method => :post 
  match 'delete_customer' => 'customers#delete_customer', :as => :delete_customer , :method => :post
  
##################################################
##################################################
######### VEHICLE
##################################################
##################################################
  match 'update_vehicle/:vehicle_id' => 'vehicles#update_vehicle', :as => :update_vehicle , :method => :post 
  match 'delete_vehicle' => 'vehicles#delete_vehicle', :as => :delete_vehicle , :method => :post
  match 'maintenance_histories/:vehicle_id' => 'service_items#maintenance_histories', :as => :maintenance_histories 
  
##################################################
##################################################
######### VENDOR
##################################################
##################################################
  match 'update_stock_conversion/:vendor_id' => 'stock_conversions#update_stock_conversion', :as => :update_stock_conversion , :method => :post 
  match 'delete_stock_conversion' => 'stock_conversions#delete_stock_conversion', :as => :delete_stock_conversion , :method => :post
end
