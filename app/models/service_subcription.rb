class ServiceSubcription < ActiveRecord::Base
  attr_accessible :employee_id, :service_item_id
  belongs_to :service_item 
  belongs_to :employee 
end
