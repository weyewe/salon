class ServiceItemsController < ApplicationController
  
  def service_done_by_employee
    @employee = Employee.find_by_id params[:employee_id]
    
    respond_to do |format|
      format.html   do
        @service_items = @employee.confirmed_services.joins(:service,  :sales_entry => [:sales_order] )
        @commissions = @service_items.sum("commission_per_employee")
      end
      
      format.js do 
        puts "we are inside the js\n"*10
         @range = parse_period_range(params[:service_period_range])
         @service_items = @employee.confirmed_services_within_period(@range[0], @range[1]).
                            joins(:service,  :sales_entry => [:sales_order] )
                            
         @commissions = @service_items.sum("commission_per_employee")
      end
    end
    
    
  end
  
  def maintenance_histories
    @vehicle = Vehicle.find_by_id params[:vehicle_id]
    @service_items = @vehicle.service_items.order("confirmed_datetime DESC").limit(10).joins(:service)
    
    add_breadcrumb "Vehicle", 'new_vehicle_url'
    set_breadcrumb_for @vehicle, 'maintenance_histories_url' + "(#{@vehicle.id})", 
                "Maintenance History for #{@vehicle.id_code}"
                
  end
  
  
  
end
