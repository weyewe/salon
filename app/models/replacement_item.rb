class ReplacementItem < ActiveRecord::Base
  attr_accessible :service_item_id, :item_id
  belongs_to :service_item
  belongs_to :item 
end
