require 'spec_helper'

=begin
  TEST PLAN
  
  1. create stock migration ( 2 ) # => 2
  2. create purchase order ( 1 )  # => 3
  3. create purchase order ( 3 ) # => 6
    4. create sales order 1 ( -5 ) # => 1 => 2 from migration, 1 from purchase order1 , 2 from purchase order 2 
  5. create purchase order ( 2 ) # => 3 
 
    6. Create Sales Order  2  ( -2 ) => 1 
    
  7. Create Sales Return for sales order 1  ( + 1 ) => 2 
=end

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
                                                  
    # create ITEM STOCK MIGRATION
    @pertamina_migration_quantity = 2
    @pertamina_migration_price = BigDecimal('150000')
    @migration_stock_entry = StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
          @pertamina_migration_quantity,  @pertamina_migration_price)
          
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
  end
  
  it 'should have correct ready item 0 -> 5' do
    @pertamina_lubricant_5L.ready.should == ( @pertamina_migration_quantity + @first_pertamina_quantity + @second_pertamina_quantity)
  end
  
  context "creating sales order that spans multiple stock_entries (-4)" do
    before(:each) do
      @sales_remaining_quantity = 1 
      @sales_quantity = @pertamina_lubricant_5L.ready - @sales_remaining_quantity
      @sales_price = BigDecimal("210000")
      @sales_order = SalesOrder.create_sales_order( @admin, @wilson  ) 
      @pertamina_sales_entry  = @sales_order.add_sales_entry_item( @pertamina_lubricant_5L, @sales_quantity  , @sales_price )
      
      @sales_order.confirm_sales(@admin)
      @pertamina_lubricant_5L.reload
      @sales_order.reload 
    end
    
    it 'should have confirmed sales order' do
      @sales_order.is_confirmed?.should be_true 
    end
    
    it 'should have deducted the ready item' do
      @pertamina_lubricant_5L.ready.should == @sales_remaining_quantity
    end
    
    it 'should have created 3 stock mutations from 3 stock entries' do
      @sales_order.stock_entries.count.should == 3 
      @sales_order.stock_mutations.count.should == 3 
    end
    
    it 'should have marked 2 stock entries as finished'  do 
      stock_entries = @sales_order.stock_entries.order("created_at ASC") 
      stock_entries[0..1].each do |stock_entry|
        stock_entry.quantity.should == stock_entry.used_quantity
        stock_entry.is_finished?.should be_true 
      end
      
      last_stock_entry  = stock_entries.last
      last_stock_entry.is_finished?.should be_false 
      (last_stock_entry.quantity - last_stock_entry.used_quantity).should == @sales_remaining_quantity 
    end
    
    context "creating purchase order to create new stock entry (+2)" do 
      before(:each) do
        @third_pertamina_quantity = 2
        @third_pertamina_price = BigDecimal("200000")
        @third_purchase_order = PurchaseOrder.create_purchase_order( @admin, @toyota_vendor) 
        @third_purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @third_pertamina_quantity,   @third_pertamina_price )
        @third_purchase_order.confirm_purchase(@admin)
        @third_stock_entry = @second_purchase_order.stock_entries.first
        
        @pertamina_lubricant_5L.reload 
      end
      
      it 'should add the ready item' do 
        @pertamina_lubricant_5L.ready.should == @sales_remaining_quantity + @third_pertamina_quantity
      end
      
       
    end # end of third purchase order
    
  end # end of the sales order creation
  
end # end of the complex scenario