class Compatibility < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :item
  belongs_to :service_component
end
