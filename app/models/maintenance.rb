class Maintenance < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :vehicle
  belongs_to :sales_order 
  has_many :sales_entries 
end
