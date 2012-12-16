class ServiceUsage < ActiveRecord::Base
  attr_accessible :service_item_id, :compatibility_id, :service_component_id, :sales_order_id
  belongs_to :service_item 
  belongs_to :sales_order 
  belongs_to :compatibility
  
  belongs_to :service_component
end
