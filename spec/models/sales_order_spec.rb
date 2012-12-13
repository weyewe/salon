require 'spec_helper'

describe SalesOrder do
  before(:each) do
    @admin = FactoryGirl.create(:user, :email => "admin@gmail.com", :password => "willy1234", :password_confirmation => "willy1234")
    @joko = FactoryGirl.create(:employee, :name => "Willy")
    @joko = FactoryGirl.create(:employee, :name => "Joko")
    @joni = FactoryGirl.create(:employee, :name => "Joni")
    
    @jakarta = FactoryGirl.create(:town, :name => "Jakarta")
    @lampung = FactoryGirl.create(:town, :name => "Lampung")
    
    @base_category = FactoryGirl.create(:category, :name => "Base") 
    @body_category = @base_category.create_sub_category( :name => "BodyPart")
    @engine_category = @base_category.create_sub_category( :name => "Engine")
    @lubricant_category = @engine_category.create_sub_category( :name => "Lubricant")
    
    @toyota_vendor = FactoryGirl.create(:vendor, :name => "Toyota Puri",
                        :contact_person => "Wilson",
                        :mobile => "08161437707")
    
    @bangjay_vendor = FactoryGirl.create(:vendor, :name => "Bangka Jaya",
                        :contact_person => "Rudi",
                        :mobile => "081612337707")
                        
    @shell_lubricant_5L = FactoryGirl.create(:item, :category_id => @lubricant_category.id , 
                          :recommended_selling_price => BigDecimal("50000"),
                          :name => "Shell Lubricant 5L"
              )
    
    @pertamina_lubricant_5L = FactoryGirl.create(:item, :category_id => @lubricant_category.id , 
                          :recommended_selling_price => BigDecimal("45000"),
                          :name => "Pertamina Lubricant 5L"
              )
              
    
    @willy = FactoryGirl.create(:customer,           :name => "Weyewe",
                                            :contact_person => "Willy",
                                            :town_id => @jakarta.id ) 

    @wilson = FactoryGirl.create(:customer,           :name => "Alfindo",
                                              :contact_person => "Wilson Gozali" ,
                                              :town_id => @lampung.id) 
    
    @vios_b_1725_bad = @willy.new_vehicle_registration( @admin ,  :id_code => "B1725BAD")    
    @rush_b_1665_bsf = @willy.new_vehicle_registration( @admin , :id_code => "B 1725Bsf")    
    
    @lubricant_replacement = FactoryGirl.create(:service, :name => "Lubricant Replacement", 
                                                  :recommended_selling_price => BigDecimal("100000"),
                                                  :commission_per_employee => BigDecimal('10000')) 
                                                  
    # create some stock migrations 
    
    @pertamina_quantity = 5
    @pertamina_price = BigDecimal('150000')
    StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
          @pertamina_quantity,  @pertamina_price)
          
    @shell_quantity = 3
    @shell_price = BigDecimal('250000')
    StockMigration.create_item_migration(@admin, @shell_lubricant_5L, 
          @shell_quantity,  @shell_price)
  end
  
  context 'creating the sales order' do
    it 'should allow creation if customer is nil' do
      sales_order = SalesOrder.create_sales_order( @admin,  nil   )
      sales_order.should be_valid 
      sales_order.customer_id.should be_nil 
      
      
    end
     
    
    it 'should allow creation if customer  is not nil'   do
      sales_order = SalesOrder.create_sales_order( @admin, @willy   )
      sales_order.should be_valid 
      sales_order.customer_id.should == @willy.id
    end
    
    it 'should not allow confirmation if there is no sales entry' do
      @sales_order = SalesOrder.create_sales_order( @admin, @willy  )
      result = @sales_order.confirm_sales( @admin ) 
      result.should be_nil 
      @sales_order.is_confirmed?.should be_false 
    end
     
    
  end
  
  # 1. adding sales_entry -> the logic for CRUD is locked  in sales_entry_spec.rb 
  context "sales_invoice confirmation" do 
    before(:each) do
      # create the sales order 
      @sales_order = SalesOrder.create_sales_order( @admin, @willy  )
      @sales_order_shell_price = @shell_price + BigDecimal('40000')
      @sales_order_shell_quantity =  @shell_quantity -1  
      @sales_order_pertamina_price = @pertamina_price - BigDecimal('10000')
      @sales_order_pertamina_quantity = @pertamina_quantity -1
      @shell_sales_entry = @sales_order.add_sales_entry_item( @shell_lubricant_5L,  @sales_order_shell_quantity  ,@sales_order_shell_price )
      @pertamina_sales_entry = @sales_order.add_sales_entry_item( @pertamina_lubricant_5L,  @sales_order_pertamina_quantity , @sales_order_pertamina_price )          
      
      @initial_shell_ready = @shell_lubricant_5L.ready 
      @initial_pertamina_ready =    @pertamina_lubricant_5L.ready
                                        
    end
    
    it 'should produce total price based on the given custom price' do
      @total_price = BigDecimal('0')
      @total_price += @sales_order_shell_quantity * @sales_order_shell_price
      @total_price += @sales_order_pertamina_quantity * @sales_order_pertamina_price 
      @sales_order.total_amount_to_be_paid.should == @total_price
    end
    
    it 'should allow confirmation if there is quantity available' do
      @result = @sales_order.confirm_sales( @admin)  
      @sales_order.is_confirmed?.should be_true  
    end
    
    context 'item ready is finished by competing confirmation sales order' do
      before(:each) do
        @competing_sales_order = SalesOrder.create_sales_order( @admin, @wilson  ) 
        @shell_lubricant_5L.reload
        @pertamina_lubricant_5L.reload 
        # puts "this is the competing bomb\n"*10
        
        # puts "******* #{@shell_lubricant_5L.name}, ready: #{@shell_lubricant_5L.ready}, requested: #{@shell_lubricant_5L.ready }"
        @competing_shell_sales_entry = @competing_sales_order.add_sales_entry_item( @shell_lubricant_5L,  @shell_lubricant_5L.ready  ,@shell_price )
        @competing_pertamina_sales_entry = @competing_sales_order.add_sales_entry_item( @pertamina_lubricant_5L,  @pertamina_lubricant_5L.ready , @pertamina_price )
       
        @competing_shell_sales_entry.should be_valid
        @competing_pertamina_sales_entry.should be_valid
      
        @competing_sales_order.confirm_sales( @admin)  
        @competing_sales_order.is_confirmed?.should be_true 
        @shell_lubricant_5L.reload
        @pertamina_lubricant_5L.reload
        
        @shell_lubricant_5L.ready.should == 0 
        @pertamina_lubricant_5L.ready.should == 0
        
      end
      
      it 'should not allow the bypassed sales order, if the item.ready is less sales_entry.quantity' do
        @sales_order.confirm_sales(@admin)
        @sales_order.is_confirmed?.should be_false 
      end 
    end
    
    
    context 'confirmed sales order' do
      before(:each) do
        @sales_order.confirm_sales( @admin)  
        @shell_lubricant_5L.reload
        @pertamina_lubricant_5L.reload
      end
      
      it 'should not double confirm' do
        @result = @sales_order.confirm_sales( @admin)  
        @result.should be_nil 
      end
      
      it 'should deduct the item accordingly' do
        ( @initial_shell_ready - @shell_lubricant_5L.ready ).should == @shell_sales_entry.quantity
        ( @initial_pertamina_ready - @pertamina_lubricant_5L.ready ).should == @pertamina_sales_entry.quantity
      end
      
      # basic case, assume from single stock entry.. later on, more complicated case, from different stock entries 
      it 'should create at least 1 stock mutation for all product sales entry' do 
        @sales_order.active_sales_entries.where(:entry_case => SALES_ENTRY_CASE[:item] ).each do |sales_entry|
          StockMutation.where( 
            :source_document_entry_id  =>  sales_entry.id  ,
            :source_document_id  =>  @sales_order.id  ,
            :source_document_entry     =>  sales_entry.class.to_s,
            :source_document    =>  @sales_order.class.to_s,
            :mutation_case      =>MUTATION_CASE[:sales_order],
            :mutation_status => MUTATION_STATUS[:deduction],
            :item_id => sales_entry.entry_id ,
            :item_status => ITEM_STATUS[:ready]
          ).count == 1  
        end
      end
      
      it '[ACCOUNTING] should increase the cash, deduct the Inventory, add CoGS, add Revenue' # to bad, no accounting yet 
      
    end 
  end # end of context "sales invoice confirmation"
  
  
  context "sales confirmation accross several stock entries" do
    before(:each) do
      @first_pertamina_quantity = 2
      @first_pertamina_price = BigDecimal("250000")

      @second_pertamina_quantity = 2
      @second_pertamina_price = BigDecimal("200000")

      StockEntry.where(:entry_case => STOCK_ENTRY_CASE[:purchase], :item_id =>@pertamina_lubricant_5L.id ).count.should == 0 
      @purchase_order = PurchaseOrder.create_purchase_order( @admin, nil)
      @purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @first_pertamina_quantity,   @first_pertamina_price )
      @purchase_order.confirm_purchase(@admin)

      @second_purchase_order = PurchaseOrder.create_purchase_order( @admin, nil)
      @second_purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @second_pertamina_quantity,   @second_pertamina_price )
      @second_purchase_order.confirm_purchase(@admin)
      @pertamina_lubricant_5L.reload
    end 
    
    it 'should produce total quantity ==  sum of all purchases' do
      @purchase_order.is_confirmed?.should be_true 
      @second_purchase_order.is_confirmed?.should be_true 
       
      @pertamina_lubricant_5L.ready.should == (@second_pertamina_quantity + @first_pertamina_quantity + @pertamina_quantity)
      
      StockEntry.where(:entry_case => STOCK_ENTRY_CASE[:purchase], :item_id =>@pertamina_lubricant_5L.id ).count.should == 2 
      StockEntry.where( :item_id =>@pertamina_lubricant_5L.id ).count.should == 3
      
    end
    
    context "creating  sales order that spans multiple stock entries" do
      # pertamina quantity = 5 
      # first pertamina quantity = 2 
      # second pertamina quantity = 2
      # what if I order 8 -> Will eat the pertamina quantity (all), first (2) , and second (1)
      before(:each) do

        @remaining_quantity = 1 
        @experiment_quantity = @pertamina_lubricant_5L.ready  - @remaining_quantity
        @sales_order = SalesOrder.create_sales_order( @admin, @wilson  ) 
        @pertamina_sales_entry  = @sales_order.add_sales_entry_item( @pertamina_lubricant_5L, @experiment_quantity  , @pertamina_price ) 
        @sales_order.confirm_sales( @admin) 
        @sales_order.reload
      end
      
      it 'should be confirmed' do
        @sales_order.is_confirmed?.should be_true 
      end
      
      it 'should have 3 stock entries, 3 stock mutations' do
        @sales_order.stock_entries.count.should == 3 
        @sales_order.stock_mutations.count.should == 3 
      end
      
      it 'should deduct the number of ready' do
        
        @pertamina_lubricant_5L.reload
        
        # puts "9999999999999999"
        # puts "#{@pertamina_lubricant_5L.name}'s ready is #{@pertamina_lubricant_5L.ready}"
        #  puts "remaining quantity is #{@remaining_quantity}"
        @pertamina_lubricant_5L.ready.should == @remaining_quantity 
      end
      
      it 'should create 3 stock mutation (deduction)' do
        @pertamina_sales_entry.stock_mutations.count ==  3 
        @pertamina_sales_entry.stock_mutations.sum("quantity").should == @experiment_quantity
      end
      
      it 'stock deduction should come from 3 stock entries, in ascending order' do 
        @pertamina_sales_entry.stock_entries.count.should == 3 
      end
      
      it 'should mark the first 2 stock entry as finished, and the last one is having 1 remnant' do
        stock_entries = @pertamina_sales_entry.stock_entries
        stock_entries[0..1].each do |x|
          x.is_finished?.should be_true 
          (x.quantity - x.used_quantity).should == 0 
        end
        
        stock_entries[2].is_finished?.should be_false 
        
        (stock_entries[2].quantity - stock_entries[2].used_quantity).should ==  @remaining_quantity
      end 
    end # end of the sales order multiple stock entries confirmation 
  end
end
