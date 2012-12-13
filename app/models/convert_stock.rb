# the class that will convert the stock, from item A to item B
# stock keeping-wise, it is working. How about the $$$ side of biz? not yet
# when item A is converted.. the item B's CoGS is added by item A COGS/ quantity 

# CAN'T BE DELETED? YEAh.. it can't 

class ConvertStock < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :stock_conversion
  
  
  def deduct_source_one_on_one(employee)
    source = self.stock_conversion.one_to_one_source 
    
    StockMutation.deduct_ready_stock(
            employee, 
            1 ,  # quantity  BECAUSE ONE_ON_ONE, it is always  1 
            source.item ,  # item 
            self, #source_document
            self, # source_document_entry,
            MUTATION_CASE[:stock_conversion_source], # mutation_case 
            MUTATION_STATUS[:deduction] # mutation_status
          )
  end
  
  def add_target_one_on_one(employee)
    
    deduction_stock_mutation = StockMutation.where(
      :source_document_entry_id => self.id,
      :mutation_case => MUTATION_CASE[:stock_conversion_source],
      :mutation_status => MUTATION_STATUS[:deduction] ,
      :item_id => self.stock_conversion.one_to_one_source.item_id
    ).first 
    
    deduction_stock_entry = deduction_stock_mutation.stock_entry
    base_price = deduction_stock_entry.base_price_per_piece
    
    target = self.stock_conversion.one_to_one_target  
    
    new_stock_entry = StockEntry.new 
    new_stock_entry.creator_id = employee.id
    new_stock_entry.quantity = target.quantity
    new_stock_entry.base_price_per_piece  = base_price / target.quantity

    new_stock_entry.item_id  = target.item_id

    new_stock_entry.entry_case =  STOCK_ENTRY_CASE[:stock_conversion]
    new_stock_entry.source_document = self.class.to_s 
    new_stock_entry.source_document_id = self.id 
    new_stock_entry.save
    
    item  = new_stock_entry.item 
    item.add_stock_and_recalculate_average_cost_post_stock_entry_addition( new_stock_entry ) 
    
    StockMutation.create(
      :quantity            =>  new_stock_entry.quantity  ,
      :stock_entry_id      =>  new_stock_entry.id ,
      :creator_id          =>  employee.id ,
      :source_document_entry_id  =>  self.id  ,
      :source_document_id  =>  self.id  ,
      :source_document_entry     =>  self.class.to_s,
      :source_document    =>  self.class.class.to_s,
      :mutation_case      => MUTATION_CASE[:stock_conversion_target],
      :mutation_status => MUTATION_STATUS[:addition],
      :item_id => new_stock_entry.item_id
    )
  end
  
  
  # one to one is not recognized anymore over here. 
  # it is only @ the UI layer 
  def execute_conversion_one_on_one(employee) 
    # deduct all the source
    # add all the targets 

    self.source_quantity.times.each do |x| 
      self.deduct_source_one_on_one(employee) 
      self.add_target_one_on_one(employee)  
    end # looping all the quantity 
    
    return self
  end
  
end
