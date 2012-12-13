require 'spec_helper'

describe ScrapItem do
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
    
    @scrap_quantity = 3 
  end
  
  it 'should create scrap item if the item is available and the quantity is not 0' do 
    @scrap_item = ScrapItem.create_scrap( @admin, @pertamina_lubricant_5L, @scrap_quantity) 
    @scrap_item.should be_valid
    @pertamina_lubricant_5L.reload 
    (@pertamina_quantity - @pertamina_lubricant_5L.ready).should == @scrap_quantity 
  end
  
  it 'should not create scrap if the quantity is less or equal to 0' do
    
    @scrap_item = ScrapItem.create_scrap( @admin, @pertamina_lubricant_5L, 0)
    @scrap_item.should_not be_valid 
  end
  
  context "post scrap item creation (trivial case, only spanning 1 stock entry)" do
    before(:each) do 
      @initial_ready = @pertamina_lubricant_5L.ready
      @initial_scrap = @pertamina_lubricant_5L.scrap
      @scrap_item = ScrapItem.create_scrap( @admin, @pertamina_lubricant_5L, @scrap_quantity)
      @pertamina_lubricant_5L.reload 
    end
    
    it 'should deduct item ready quantity and increase the scrap quantity' do
      ( @initial_ready - @pertamina_lubricant_5L.ready ).should == @scrap_quantity
      ( @pertamina_lubricant_5L.scrap  - @initial_scrap). should == @scrap_quantity
      
      @scrap_item.item_id.should == @pertamina_lubricant_5L.id 
    end
    
    it 'should create 1 stock mutation and 1 stock entry for item[ready] deduction' do
      @scrap_item.stock_mutations_for_ready_item_deduction.count.should == 1 
      @scrap_item.deducted_stock_entries.count.should == 1 
    end 
    
    it 'should create 1 stock mutation for item[scrap] addition' do 
      @scrap_item.stock_mutations_for_scrap_item_addition.count.should == 1 
    end
    
  end # end of context "post scrap item creation"
  
  context 'post scrap item creation (generic case: spanning several stock entries)' do
    before(:each) do
      @first_pertamina_quantity = 2 
      @first_pertamina_price = BigDecimal('150000')
      @first_purchase_order = PurchaseOrder.create_purchase_order( @admin, @toyota_vendor) 
      @first_purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @first_pertamina_quantity,   @first_pertamina_price )
      @first_purchase_order.confirm_purchase(@admin)
      
      @second_pertamina_quantity = 3
      @second_pertamina_price = BigDecimal('180000')
      @second_purchase_order = PurchaseOrder.create_purchase_order( @admin, @toyota_vendor) 
      @second_purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @second_pertamina_price,   @second_pertamina_quantity )
      @second_purchase_order.confirm_purchase(@admin) 
      
      @remaining_quantity = 1 
      @pertamina_lubricant_5L.reload 
      
      @initial_ready = @pertamina_lubricant_5L.ready 
      @initial_scrap =  @pertamina_lubricant_5L.scrap 
      @total_scrap_quantity = @pertamina_quantity + @first_pertamina_quantity + @second_pertamina_quantity - @remaining_quantity
      @scrap_item = ScrapItem.create_scrap( @admin, @pertamina_lubricant_5L, @total_scrap_quantity)
      @pertamina_lubricant_5L.reload 
    end
    
    it 'should create 3 stock mutations and 3 stock entry for item[ready] deduction' do
      @scrap_item.stock_mutations_for_ready_item_deduction.count.should == 3 
      @scrap_item.deducted_stock_entries.count.should == 3
    end
    
    it 'should create 1 stock mutation for item[scrap] addition' do 
      @scrap_item.stock_mutations_for_scrap_item_addition.count.should == 3
    end
    
    it 'should deduct item ready quantity and increase the scrap quantity' do
      ( @initial_ready - @pertamina_lubricant_5L.ready ).should == @scrap_item.stock_mutations_for_ready_item_deduction.sum('quantity')
      ( @pertamina_lubricant_5L.scrap  - @initial_scrap). should == @scrap_item.stock_mutations_for_scrap_item_addition.sum('quantity')
    end
  end
  
end
