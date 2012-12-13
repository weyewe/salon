require 'spec_helper'

describe SalesEntry do
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
          
    @sales_order = SalesOrder.create_sales_order( @admin,  nil   )
  end
  
  context 'adding PRODUCT sales entry to sales order' do
    
    
    context 'create sales_entry' do
      before(:each) do
        
        @pertamina_sales_entry_quantity = @pertamina_quantity - 1
        @pertamina_sales_entry_selling_price = @pertamina_price + BigDecimal("10000")
        @sales_entry = @sales_order.add_sales_entry_item( @pertamina_lubricant_5L,    
                                                            @pertamina_sales_entry_quantity, 
                                                            @pertamina_sales_entry_selling_price )
      end
      
      
      it 'should create sales entry, product type'  do
        @sales_entry.should be_valid 

        @sales_entry.quantity.should == @pertamina_sales_entry_quantity

        @sales_entry.is_product?.should be_true
        @sales_entry.is_service?.should be_false 
        @sales_entry.item.id.should == @pertamina_lubricant_5L.id 
      end

      it 'should not allow double sales entry' do
        
        
        @new_sales_entry = @sales_order.add_sales_entry_item( @pertamina_lubricant_5L,    
                                                            1, 
                                                            @pertamina_sales_entry_selling_price )
        
        @new_sales_entry.should_not be_valid   
        @new_sales_entry.errors.messages.length.should == 1  
      end
      
      it 'should not allow selling price less than 0' do
        @new_sales_entry = @sales_order.add_sales_entry_item( @shell_lubricant_5L,    
                                                            1, 
                                                            BigDecimal('0') )
        
        @new_sales_entry.should_not be_valid   
        @new_sales_entry.errors.messages.length.should == 1
      end
      
      it 'should not allow quantity less than 1' do
        @new_sales_entry = @sales_order.add_sales_entry_item( @shell_lubricant_5L,    
                                                            0, 
                                                             BigDecimal("50000") )
        
        @new_sales_entry.should_not be_valid   
        @new_sales_entry.errors.messages.length.should == 1
      end
       
    end 
  end
  
  context 'adding SERVICE sales entry to sales order' do
     context "create sales_entry" do
       before(:each) do
       end
     end
  end
  
  
end
