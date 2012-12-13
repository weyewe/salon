class Vendor < ActiveRecord::Base
  attr_accessible :name, :contact_person, :phone, :mobile , :email, :bbm_pin, :address
  
  validates_presence_of :name 
  validates_uniqueness_of :name 
  
  
  
  def self.active_vendors
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def delete
    self.is_deleted = true
    self.save
  end
  
end
