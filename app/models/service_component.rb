class ServiceComponent < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :service 
  has_many :items, :through => :compatibilities
  has_many :compatibilities 
end
