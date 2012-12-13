class ConversionEntry < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :stock_conversion 
  belongs_to :item 
  
  
  def is_source?
    self.entry_status ==  STOCK_CONVERSION_ENTRY_STATUS[:source]
  end
  
  def is_target?
    self.entry_status ==  STOCK_CONVERSION_ENTRY_STATUS[:target]
  end
end
