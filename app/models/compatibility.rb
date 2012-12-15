class Compatibility < ActiveRecord::Base
  attr_accessible :item_id, :quantity
  belongs_to :item
  belongs_to :service_component
  
  validates_presence_of :item_id 
  validates_presence_of :quantity
end
