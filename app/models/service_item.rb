class ServiceItem < ActiveRecord::Base
  attr_accessible  :sales_entry_id , :service_id 
  has_many :employees, :through => :service_subcriptions 
  has_many :service_subcriptions 

  has_many :items, :through => :replacement_items 
  has_many :replacement_items 
  
  belongs_to :sales_entry 
  belongs_to :service 
  belongs_to :vehicle
  
  has_many :service_usages
  
  
  # only 1 employee per service 
  # def add_employee_participation( employee ) 
  #   current_subcriptions = self.service_subcriptions  
  #   
  #   if current_subcriptions.length != 0  
  #     current_subcriptions.each do |x|
  #       puts "3321 destroying, employee id is #{x.employee_id}"
  #       x.destroy 
  #     end
  #   end
  #   
  #   puts "Gonna create service subcription "
  #   ServiceSubcription.create :employee_id => employee.id, :service_item_id => self.id 
  # end
  
  # adding multiple employees 
  def add_employees_participation(employee_list ) 
     
     # clean up the current_subcription
     self.service_subcriptions.each do |x|
       x.destroy 
     end
     
     employee_list.each do |employee|
       ServiceSubcription.create :employee_id => employee.id, :service_item_id => self.id 
     end
  end
  
 
  
  def create_replacement_items( item_list   ) 
    # ensure that all the items belongs to the company 
     service_object = self.service 
     
     # clean up
     self.replacement_items.each do |replacement_item|
       replacement_item.destroy 
     end
     
     # create new 
     item_list.each do |item|  
       ReplacementItem.create(:service_item_id=> self.id , :item_id => item.id )
     end 
  end
  
  
   
  
  def delete
    self.is_deleted = true
    self.save 
  end
  
  def selected_employees_id_list 
    self.employees.map{|x| x.id }
  end
end
