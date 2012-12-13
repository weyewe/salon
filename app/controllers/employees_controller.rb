class EmployeesController < ApplicationController
  
  
  def new 
    @objects = Employee.active_employees
    @new_object = Employee.new
    
    respond_to do |format|
      format.html   
      format.js  
    end 
  end
  
  def create
    
    @object = Employee.create(   params[:employee])
    
    
    if @object.valid?
      @new_object=  Employee.new
    else
      @new_object= @object
    end
  end
  
  def edit
    @employee = Employee.find_by_id params[:id] 
  end
  
  def update_employee
    @employee = Employee.find_by_id params[:employee_id] 
    @employee.update_attributes( params[:employee])
    @has_no_errors  = @employee.errors.messages.length == 0
  end
  
  def delete_employee
    @employee = Employee.find_by_id params[:object_to_destroy_id]
    @employee.delete 
  end
end
