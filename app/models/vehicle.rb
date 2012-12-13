class Vehicle < ActiveRecord::Base 
  attr_accessible :id_code , :customer_id 
  belongs_to :customer 
  has_many :sales_orders 
  has_many :service_items  # service item == maintenance 
  
  # has_many :maintenances  # 1 sales order is assumed to be 1 maintenance 
  # has_many :ownership_mutation 
  
  validates_presence_of :id_code
  validates_uniqueness_of :id_code  # give scope company_id , and is_deleted => false 
  
  def self.active_vehicles
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def delete
    self.is_deleted = true
    self.save
  end
  
  def maintenance_histories
    self.service_items.where(:is_confirmed => true ).order("created_at DESC")
  end
end
