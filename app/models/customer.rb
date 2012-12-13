class Customer < ActiveRecord::Base
  attr_accessible :name, :contact_person, :phone, :mobile , :email, :bbm_pin, :address, :town_id , :office_address, :delivery_address
  has_many :vehicles 
  
  validates_presence_of :name 
  validates_uniqueness_of :name
  
  has_many :sales_orders 
  belongs_to :town 
  
  def new_vehicle_registration( employee ,  vehicle_params ) 
    id_code = vehicle_params[:id_code]
    if not id_code.present? 
      return nil
    end
    
    
    self.vehicles.create :id_code =>  id_code.upcase.gsub(/\s+/, "") 
  end
  
  def self.active_customers
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def delete
    self.is_deleted = true
    self.save 
  end
end
