class Employee < ActiveRecord::Base
  attr_accessible :name, :mobile_phone , :address 
  has_many :service_items, :through => :service_subcriptions
  has_many :service_subcriptions 
  
  after_create :add_employee_code
  validates_presence_of :name 
  validates_uniqueness_of :name , :case_sensitive => false 
  
  
  def add_employee_code
    year = DateTime.now.year 
    month = DateTime.now.month  
    total_employee_created_this_month = Employee.where(:year => year.to_i, :month => month.to_i).count  

    code =  'EM/' + year.to_s + '/' + 
                        month.to_s + '/' + 
                        (total_employee_created_this_month + 1 ).to_s
                        
    self.year = year 
    self.month = month 
    self.code = code
    self.save 
  end
  
  def self.active_employees
    Employee.where(:is_deleted => false ) 
  end
  
  def confirmed_services
    self.service_items.where(:is_confirmed => true , :is_deleted => false )
  end
  
  def confirmed_services_within_period(start_date, end_date) 
    # start_date and end_date is in UTC 
    # bring it to local time 
    start_date_utc =  start_date.to_time_in_current_zone.utc 
    end_date_utc   =  end_date.to_time_in_current_zone.utc 
    
    # bring this to local time 
    self.confirmed_services.where(:confirmed_datetime => start_date..end_date  ) 
    
  end
  
  def delete
    self.is_deleted = true 
    self.save 
  end
end
