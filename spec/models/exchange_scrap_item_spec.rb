require 'spec_helper'

describe ExchangeScrapItem do
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
    @migration_stock_entry = StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
          @pertamina_quantity,  @pertamina_price) 
  end
  
  context "trivial exchange scrap: only from 1 stock entry" do 
    before(:each ) do
      @scrap_quantity = 3 
      @scrap_item = ScrapItem.create_scrap( @admin, @pertamina_lubricant_5L, @scrap_quantity) 
      @pertamina_lubricant_5L.reload
      
      @remaining_quantity = 1 
      @exchange_quantity = @scrap_quantity - @remaining_quantity
      @exchange_scrap_item = ExchangeScrapItem.create_exchange_scrap( @admin, @pertamina_lubricant_5L, @exchange_quantity)
    end
    
    it 'should exchange scrap item' do 
      @exchange_scrap_item.should be_valid 
    end
    
    it 'should create 1 stock mutation for deducting the scrap item, and 1 stock mutation for adding the ready item' do
      @exchange_scrap_item.stock_mutations_to_deduct_scrap_item.count.should == 1 
      @exchange_scrap_item.stock_mutations_to_add_ready.count.should == 1 
    end
  end
  
  context "complex exchange scrap1: toggling the is_finished in stock entry because we recovered the scrap item" do
    before(:each) do
      
      @remaining_quantity = 1 
      # buy 4 
      @sales_order = SalesOrder.create_sales_order( @admin, @wilson  ) 
      @sales_order_quantity = @pertamina_quantity - @remaining_quantity
      @pertamina_sales_entry  = @sales_order.add_sales_entry_item( @pertamina_lubricant_5L, @sales_order_quantity  , @pertamina_price ) 
      @sales_order.confirm_sales( @admin) 
      @pertamina_lubricant_5L.reload 
      
      # scrap 1 
      @scrap_item = ScrapItem.create_scrap( @admin, @pertamina_lubricant_5L, @remaining_quantity) 
      @pertamina_lubricant_5L.reload
      @migration_stock_entry.reload
    end
    
    it 'should have finished the stock' do
      @migration_stock_entry.is_finished?.should be_true 
      @migration_stock_entry.scrapped_quantity.should == @remaining_quantity
    end
    
    it 'should unmark the is_finished on exchange item' do
      @exchange_scrap_item = ExchangeScrapItem.create_exchange_scrap( @admin, @pertamina_lubricant_5L, @remaining_quantity)
      @migration_stock_entry.reload
      @migration_stock_entry.is_finished?.should be_false 
      @migration_stock_entry.scrapped_quantity.should == 0 
    end
  end
  
  context "complex exchange scrap2: spanning several stock entries, but sequential" do
    before(:each) do
      # create ITEM PURCHASE  #1 
      @first_pertamina_quantity = 1 
      @first_pertamina_price = BigDecimal("200000")
      @first_purchase_order = PurchaseOrder.create_purchase_order( @admin, @toyota_vendor) 
      @first_purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @first_pertamina_quantity,   @first_pertamina_price )
      @first_purchase_order.confirm_purchase(@admin) 
      @first_stock_entry = @first_purchase_order.stock_entries.first 


      @second_pertamina_quantity = 3
      @second_pertamina_price = BigDecimal("170000")
      @second_purchase_order = PurchaseOrder.create_purchase_order( @admin, @toyota_vendor) 
      @second_purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @second_pertamina_quantity,   @second_pertamina_price )
      @second_purchase_order.confirm_purchase(@admin)
      @second_stock_entry = @second_purchase_order.stock_entries.first 

      @pertamina_lubricant_5L.reload
      
      # total = 5 + 1 + 3 == 9 
      
      #create sales order

      @sales_remaining_quantity = 1 
      # buy 4 
      @sales_order = SalesOrder.create_sales_order( @admin, @wilson  ) 
      @sales_order_quantity = @pertamina_quantity - @sales_remaining_quantity
      @pertamina_sales_entry  = @sales_order.add_sales_entry_item( @pertamina_lubricant_5L, @sales_order_quantity  , @pertamina_price ) 
      @sales_order.confirm_sales( @admin)
      @pertamina_lubricant_5L.reload
      
      # total = (5-4)   +1 + 3 == 5 
      # scrap item spanning 3 stock entries: 1 from migration, 1 from first purchase order, 2 from second purchase order
      @scrap_quantity = 4 
      @scrap_item = ScrapItem.create_scrap( @admin, @pertamina_lubricant_5L, @scrap_quantity) 
      @pertamina_lubricant_5L.reload
      @first_stock_entry.reload
      @second_stock_entry.reload
      @migration_stock_entry.reload
    end
    
    it 'should only leave item with 1 ready' do
      @pertamina_lubricant_5L.ready.should == 1 
      @pertamina_lubricant_5L.scrap.should == 4 
    end
    
    it 'should mark the first 2 stock entries as finished' do
      @migration_stock_entry.is_finished.should be_true 
      @first_stock_entry.is_finished.should be_true
      @second_stock_entry.is_finished.should be_false
    end
    
    context 'create exchange scrap that spans all scrapped stock entries' do
      before(:each) do
        @pertamina_lubricant_5L.reload 
        @initial_ready = @pertamina_lubricant_5L.ready 
        @exchange_scrap_item = ExchangeScrapItem.create_exchange_scrap( @admin, @pertamina_lubricant_5L, @scrap_quantity) 
        @pertamina_lubricant_5L.reload 
      end
      
      it 'should produce valid exchange scrap item' do 
        @exchange_scrap_item.should be_valid 
      end
      
      it 'should return the ready quantity' do
        @pertamina_lubricant_5L.ready.should == @initial_ready + @scrap_quantity 
        @pertamina_lubricant_5L.scrap.should == 0 
      end
      
      it 'should produces 3 stock mutations for deducting scrap item and 3 mutations for adding ready item' do
        @exchange_scrap_item.stock_mutations_to_deduct_scrap_item.sum("quantity").should == @scrap_quantity 
        # @exchange_scrap_item.stock_mutations_to_deduct_scrap_item.each do |stock_mutation|
        #   puts "stock_entry :#{stock_mutation.stock_entry_id} , quantity = #{stock_mutation.quantity}"
        # end
        
        @exchange_scrap_item.stock_mutations_to_add_ready.sum("quantity").should == @scrap_quantity 
        
        @exchange_scrap_item.stock_mutations_to_deduct_scrap_item.count.should == 3
        @exchange_scrap_item.stock_mutations_to_add_ready.count.should ==3 
      end
      
      it 'should un finish the stock entry 1 and 2 ' do 
        @first_stock_entry.reload
        @second_stock_entry.reload
        @migration_stock_entry.reload
        
        @first_stock_entry.is_finished.should be_false
        @second_stock_entry.is_finished.should be_false
        @migration_stock_entry.is_finished.should be_false
      end 
    end # end of context 'create exchange scrap that spans all scrapped stock entries'
    
    context "recovery spec: recover the first created stock entry first " do
      before(:each) do
        @pertamina_lubricant_5L.reload 
        @initial_ready = @pertamina_lubricant_5L.ready 
        @incomplete_quantity=  @scrap_quantity - 2
        # total = (5-4)   +1 + 3 == 5 
        # scrap item spanning 2 stock entries: 1 from migration, 1 from first purchase order 
        @exchange_scrap_item = ExchangeScrapItem.create_exchange_scrap( @admin, @pertamina_lubricant_5L, @incomplete_quantity) 
        @pertamina_lubricant_5L.reload 
      end
      
      it 'should recover the   stock entry in ascending order, based on creation time ' do
        @exchange_scrap_item.stock_mutations_to_deduct_scrap_item.count.should == 2
        @exchange_scrap_item.stock_mutations_to_add_ready.count.should ==2 
        
        @migration_stock_entry. reload
        @first_stock_entry.reload
        @second_stock_entry.reload
        
        @migration_stock_entry.is_finished.should be_false 
        @first_stock_entry.is_finished.should be_false 
        
        @migration_stock_entry.scrapped_quantity.should == 0 
        @first_stock_entry.scrapped_quantity.should == 0 
        
        @second_stock_entry.scrapped_quantity.should_not == 0 
        
      end
    end
    
    
  end
  
  context "complex exchange scrap3: spanning several stock entries, but not sequential" do
  end
end
