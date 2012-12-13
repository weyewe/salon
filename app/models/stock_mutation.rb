class StockMutation < ActiveRecord::Base
  attr_accessible :quantity, :stock_entry_id, :source_document_entry_id, 
                  :creator_id, :source_document_id, :source_document_entry,
                  :source_document, :deduction_case,
                  :mutation_case, :mutation_status,
                  :item_id, :item_status,
                  :scrap_item_id

  belongs_to :stock_entry 
  belongs_to :scrap_item 
  belongs_to :item
  
  
 
=begin
  SETUP + ADJUSTMENT 
=end 
  def StockMutation.create_stock_adjustment( employee, stock_adjustment)
    item = stock_adjustment.item 
    if stock_adjustment.adjustment_case == STOCK_ADJUSTMENT_CASE[:addition]
      
      new_stock_entry = StockEntry.new 
      new_stock_entry.creator_id = employee.id
      new_stock_entry.quantity = stock_adjustment.adjustment_quantity
      new_stock_entry.base_price_per_piece  = item.average_cost 
      new_stock_entry.item_id  = item.id  
      new_stock_entry.entry_case =  STOCK_ENTRY_CASE[:stock_adjustment]
      new_stock_entry.source_document = stock_adjustment.class.to_s
      new_stock_entry.source_document_id = stock_adjustment.id  
      new_stock_entry.save 
      
      
      item.add_stock_and_recalculate_average_cost_post_stock_entry_addition( new_stock_entry ) 
    
      # create the StockMutation
      StockMutation.create(
        :quantity            => stock_adjustment.adjustment_quantity  ,
        :stock_entry_id      =>  new_stock_entry.id ,
        :creator_id          =>  employee.id ,
        :source_document_entry_id  =>  stock_adjustment.id   ,
        :source_document_id  =>  stock_adjustment.id  ,
        :source_document_entry     =>  stock_adjustment.class.to_s,
        :source_document    =>  stock_adjustment.class.to_s,
        :mutation_case      => MUTATION_CASE[:stock_adjustment],
        :mutation_status => MUTATION_STATUS[:addition],
        :item_id => item.id
      ) 
    else stock_adjustment.adjustment_case == STOCK_ADJUSTMENT_CASE[:deduction]
      
      
                
                
      requested_quantity =  stock_adjustment.adjustment_quantity
      
      StockMutation.deduct_ready_stock(
              employee, 
              requested_quantity, 
              item, 
              stock_adjustment, 
              stock_adjustment,
              MUTATION_CASE[:stock_adjustment], 
              MUTATION_STATUS[:deduction]  
            )
             
      
    end
  end
  
  def StockMutation.create_purchase_return(employee,   purchase_return )
    item  = purchase_return.item 
    
    
    requested_quantity =  purchase_return.quantity
    StockMutation.deduct_ready_stock(
            employee, 
            requested_quantity, 
            item, 
            purchase_return, 
            purchase_return,
            MUTATION_CASE[:purchase_return], 
            MUTATION_STATUS[:deduction]  
          )
     
              
  
    
  end
  
=begin
  UTILITY to deduct ready item without any callback
=end
  def StockMutation.deduct_ready_stock(
          employee, 
          quantity, 
          item, 
          source_document, 
          source_document_entry,
          mutation_case, 
          mutation_status  
        )
        
      requested_quantity =  quantity
      supplied_quantity = 0 

      while supplied_quantity != requested_quantity
        unfulfilled_quantity = requested_quantity - supplied_quantity 
        stock_entry =  StockEntry.first_available_stock(  item )

        #  stock_entry.nil? raise error  # later.. 
        if stock_entry.nil?
          raise ActiveRecord::Rollback, "Can't be executed. No Item in the stock" 
        end

        available_quantity = stock_entry.available_quantity 

        served_quantity = 0 
        if unfulfilled_quantity <= available_quantity 
          served_quantity = unfulfilled_quantity 
        else
          served_quantity = available_quantity 
        end

        stock_entry.update_usage(served_quantity) 
        supplied_quantity += served_quantity 

        StockMutation.create(
          :quantity            => served_quantity  ,
          :stock_entry_id      =>  stock_entry.id ,
          :creator_id          =>  employee.id ,
          :source_document_entry_id  =>  source_document_entry.id  ,
          :source_document_id  =>  source_document.id  ,
          :source_document_entry     =>  source_document_entry.class.to_s,
          :source_document    =>  source_document.class.to_s,
          :mutation_case      => mutation_case,
          :mutation_status => mutation_status,
          :item_id => stock_entry.item_id ,
          :item_status => ITEM_STATUS[:ready]
        )

      end
  end 
  
=begin
  For SALES RETURN: recover stock to the respective FIFO stock entry 
=end 

  def StockMutation.stock_mutations_for_sales_entry(sales_entry)  
    sales_order = sales_entry.sales_order
    StockMutation.where(
      :source_document_entry_id  =>  sales_entry.id  ,
      :source_document_id  =>  sales_order.id  ,
      :source_document_entry     =>  sales_entry.class.to_s,
      :source_document    =>  sales_order.class.to_s,
      :mutation_case      => MUTATION_CASE[:sales_order],
      :mutation_status => MUTATION_STATUS[:deduction],
      :item_status => ITEM_STATUS[:ready]
    ).order("created_at ASC")        # the order is to preserve the FIFO # the first stock mutation refers to the first item in ready stock
  end
  
  def StockMutation.recover_stock_from_sales_return( employee, sales_return_entry) 
    
    pending_recovery_quantity = sales_return_entry.quantity 
    sales_entry = sales_return_entry.sales_entry 
      
      # puts "***This damned batch\n"*10
      # will recover from the last consumed stock_entry 
    sales_entry.stock_entries.order("id DESC").each do |stock_entry| # created DESC 
      # puts "#{stock_entry.created_at }, id : #{stock_entry.id }"
      stock_mutation = sales_entry.stock_mutation_for( stock_entry ) 
      deducted_quantity = stock_mutation.quantity
      
      quantity_to_be_recovered =  0  
      if deducted_quantity >= pending_recovery_quantity
        # it means this is the last stock_entry to be recovered
        quantity_to_be_recovered = pending_recovery_quantity
      else
        quantity_to_be_recovered = deducted_quantity
      end
      
      stock_entry.recover_usage(quantity_to_be_recovered) 
      # recovering the stock entry and the item.ready 
      pending_recovery_quantity -= quantity_to_be_recovered 
      
      StockMutation.create(
        :quantity            => quantity_to_be_recovered  ,
        :stock_entry_id      =>  stock_entry.id ,
        :creator_id          =>  employee.id ,
        :source_document_entry_id  =>  sales_return_entry.id  ,
        :source_document_id  =>  sales_return_entry.sales_return_id  ,
        :source_document_entry     =>  sales_return_entry.class.to_s,
        :source_document    =>  sales_return_entry.sales_return.class.to_s,
        :mutation_case      => MUTATION_CASE[:sales_return],
        :mutation_status => MUTATION_STATUS[:addition],
        :item_id => stock_entry.item_id,
        :item_status => ITEM_STATUS[:ready]
      )
    end
  end

=begin
  FOR SCRAP ITEM 
  Intersection between scrap ITEM_STATUS and ready ITEM_STATUS
  stock_entry   DEDUCT STOCK_MUTATION     , source document is scrap_item 
  scrap_item    ADD STOCK_MUTATION         
=end
  def StockMutation.deduct_ready_stock_add_scrap_item( employee, scrap_item) 
    
    requested_quantity =  scrap_item.quantity 
    supplied_quantity = 0 
    
    item = scrap_item.item 

    while supplied_quantity != requested_quantity
      unfulfilled_quantity = requested_quantity - supplied_quantity 
      stock_entry =  StockEntry.first_available_stock(  item )

      #  stock_entry.nil? raise error  # later.. 
      if stock_entry.nil?
        raise ActiveRecord::Rollback, "Can't be executed. No Item in the stock" 
      end

      available_quantity = stock_entry.available_quantity 

      served_quantity = 0 
      if unfulfilled_quantity <= available_quantity 
        served_quantity = unfulfilled_quantity 
      else
        served_quantity = available_quantity 
      end

      # update the stock entry  and the item ( SCRAP + USAGE + READY)
      stock_entry.perform_item_scrapping( served_quantity) 
      
      supplied_quantity += served_quantity 

      deduct_ready_stock_mutation = StockMutation.create(
        :quantity            => served_quantity  ,
        :stock_entry_id      =>  stock_entry.id ,
        :scrap_item_id => scrap_item.id, 
        :creator_id          =>  employee.id ,
        :source_document_entry_id  =>  scrap_item.id  ,
        :source_document_id  =>  scrap_item.id  ,
        :source_document_entry     =>  scrap_item.class.to_s,
        :source_document    =>  scrap_item.class.to_s,
        :item_id => stock_entry.item_id ,
        
        :mutation_case      => MUTATION_CASE[:scrap_item],
        :mutation_status => MUTATION_STATUS[:deduction], 
        :item_status => ITEM_STATUS[:ready] # item status under mutation == ready item being deducted
      )
      
      
      
      scrap_item_stock_mutation = StockMutation.create(
        :quantity            => served_quantity  ,
        :stock_entry_id      =>  stock_entry.id ,
        :scrap_item_id => scrap_item.id, 
        :creator_id          =>  employee.id ,
        :source_document_entry_id  =>  scrap_item.id  ,
        :source_document_id  =>  scrap_item.id  ,
        :source_document_entry     =>  scrap_item.class.to_s,
        :source_document    =>  scrap_item.class.to_s,
        :item_id => stock_entry.item_id ,
        
        :mutation_case      => MUTATION_CASE[:scrap_item],
        :mutation_status => MUTATION_STATUS[:addition], 
        :item_status => ITEM_STATUS[:scrap] # item status under mutation == scrap item being added
      )

    end
    
  end
  
  
=begin
  SCRAP ITEM REPLACEMENT
  scrap_item   DEDUCT STOCK_MUTATION   ,  source document is exchange_scrap_item 
  stock_item    ADD STOCK_MUTATION
=end
  def StockMutation.deduct_scrap_add_ready_stock(  employee,  ex_scrap_item )
    # create several stock mutations to deduct scrap item
    # create several stock mutations to add scrap item    >>>> TO PRESERVE THE FIFO
    # puts "\n\n"
    # puts "################################################"
    # puts "################################################"
    # puts "################################################"
    
    
    requested_quantity =  ex_scrap_item.quantity 
    exchanged_quantity = 0 
    # puts "Requested Quantity to be exchanged: #{requested_quantity}"
    
    
    item = ex_scrap_item.item 

    while exchanged_quantity != requested_quantity
      
      pending_exchange_quantity  = requested_quantity - exchanged_quantity 
      # puts "Exchanged quantity: #{exchanged_quantity}"
      # puts "pending exchange quantity: #{pending_exchange_quantity}" 
      scrap_item  = ScrapItem.first_available_stock( item  )
      # puts  "\n################################################"
      # puts "scrap_item : #{scrap_item.id}"

      #  stock_entry.nil? raise error  # later.. 
      if scrap_item.nil?
        raise ActiveRecord::Rollback, "Can't be executed. No Scrap Item in the stock" 
      end

      unexchanged_quantity = scrap_item.unexchanged_quantity 
      # puts "\t unexchanged quantity in scrap item: #{unexchanged_quantity}"
      
      served_quantity = 0 
      if pending_exchange_quantity <= unexchanged_quantity 
        served_quantity = pending_exchange_quantity 
      else
        served_quantity = unexchanged_quantity 
      end

      
      exchanged_quantity += served_quantity 
      
      # deduct the scrap item
      
      
      recovered_quantity = 0  
      
      # scrap item come from several stock entries
      # hence, we are recovering those stock entries
      # puts "\t number of stock entries to linked to scrap_item: #{scrap_item.unrecovered_deducted_stock_entries.count}"
      # puts "\t Total available to be recovered in all stock entries: #{scrap_item.unrecovered_deducted_stock_entries.sum('scrapped_quantity')}"
      # scrap_item.unrecovered_deducted_stock_entries.each do |stock_entry|
      #   puts "\t\t stock_entry #{stock_entry.id}, unexchanged: #{stock_entry.scrapped_quantity}"
      # end
      
      scrap_item.unrecovered_deducted_stock_entries.each do |stock_entry| 
        # puts "\n"
        # puts "stock_entry #{stock_entry.id}, to be exchanged: #{stock_entry.scrapped_quantity}"
        stock_entry_scrap_quantity = stock_entry.scrapped_quantity

=begin
        # example: we replace 8 items in one go
        # those 8 items composed of 2 scrap item: 5 and 3 
        # => so, we will find the stock entry deduction for the first scrap item (5)
          # => first scrap item comes from 2 stock entries( 3 and 2 ) 
            # => so, we will recover the scrap from first stock entry ( 3 ) 
              # illustration for this thing to work
              # => served quantity = 5  (constant)
              # => the  stock_entry_scrap_quantity =  3
              # => scrap_to_recover_quantity = 5 - 0  = 5  
                # we will create the first mutation (3)
                  # => recovered_quantity = 3 , stock_entry_scrap_quantity == 0 .. move to the next stock mutation
                  
            # => then, we will recover the scrap from second stock entry ( 2 )
              # => served_quantity = 5 (constant)  
              # => stock_entry_scrap_quantity = 5 (more than we need: 2 ) 
              # => scrap_to_recover_quantity = 5-3 = 2 
                # then we will create the second mutation (2)
                  # => recovered_quantity = 5 , stock_entry_scrap_quantity == 3
=end             
        
        
        # finish the served_quantity 
        scrap_to_recover_quantity = served_quantity - recovered_quantity
        # puts "exchanged quantity == #{recovered_quantity}"
        
        while  not( scrap_to_recover_quantity == 0  or  # if the scrap to recover quantity == 0.. we have replaced enough
          stock_entry_scrap_quantity == 0)   # if stock entry scrap quantity ==0 , get the next stock entry 
          # puts "\n"
          # puts "\tscrap_to_recover_quantity: #{scrap_to_recover_quantity} "
          # puts "\tstock_entry_scrap_quantity: #{stock_entry_scrap_quantity}"
          if scrap_to_recover_quantity <= stock_entry_scrap_quantity
            recover_quantity = scrap_to_recover_quantity
          else
            recover_quantity = stock_entry_scrap_quantity
          end
          
          stock_entry.perform_scrap_item_replacement( recover_quantity  )  
  
          
          add_ready_stock_mutation = StockMutation.create(
            :quantity            => recover_quantity  ,
            :stock_entry_id      =>  stock_entry.id ,
            :scrap_item_id => scrap_item.id ,
            :creator_id          =>  employee.id ,
            :source_document_entry_id  =>  ex_scrap_item.id  ,
            :source_document_id  =>  ex_scrap_item.id  ,
            :source_document_entry     =>  ex_scrap_item.class.to_s,
            :source_document    =>  ex_scrap_item.class.to_s,
            :mutation_case      => MUTATION_CASE[:scrap_item_replacement],
            :mutation_status => MUTATION_STATUS[:addition],
            :item_id => item.id  ,
            :item_status => ITEM_STATUS[:ready]
          )
          
          deduct_scrap_stock_mutation = StockMutation.create(
            :quantity            => recover_quantity  ,
            :stock_entry_id      =>  stock_entry.id ,
            :scrap_item_id => scrap_item.id , 
            :creator_id          =>  employee.id ,
            :source_document_entry_id  =>  ex_scrap_item.id  ,
            :source_document_id  =>  ex_scrap_item.id  ,
            :source_document_entry     =>  ex_scrap_item.class.to_s,
            :source_document    =>  ex_scrap_item.class.to_s,
            :mutation_case      => MUTATION_CASE[:scrap_item_replacement],
            :mutation_status => MUTATION_STATUS[:deduction],
            :item_id => item.id ,
            :item_status => ITEM_STATUS[:scrap]
          )
          
          recovered_quantity += recover_quantity
          scrap_to_recover_quantity -= recover_quantity
          stock_entry_scrap_quantity -= recover_quantity
        end 
      end
      

    end
  end
  
  
  
end
