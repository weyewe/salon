require 'spec_helper'

describe PurchaseOrder do
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
    it 'should allow creation if vendor not nil' do
      @purchase_order = PurchaseOrder.create_purchase_order( @admin, @toyota_vendor)
      
      @purchase_order.should be_valid 
    end
    
    it 'should not allow creation if vendor  is  nil' do
      @purchase_order = PurchaseOrder.create_purchase_order( @admin, nil)
      
      @purchase_order.should_not be_valid
    end
  end
  
  context "purchase order confirmation" do
    before(:each) do
      @purchase_order = PurchaseOrder.create_purchase_order( @admin, @toyota_vendor)
      @purchase_order.should be_valid
      
      # @purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @pertamina_quantity,   @pertamina_price )
      # @purchase_order.add_purchase_entry_item( @shell_lubricant_5L,  @shell_quantity,   @shell_price )
      
      @new_pertamina_price = @pertamina_price + BigDecimal('50000')
      @new_shell_price = @shell_price + BigDecimal('80000')
      @new_pertamina_quantity = 3
      @new_shell_quantity = 2
      
      @initial_pertamina_quantity = @pertamina_lubricant_5L.ready
      @initial_pertamina_average_cost = @pertamina_lubricant_5L.average_cost
      @initial_shell_quantity = @shell_lubricant_5L.ready
      @initial_shell_average_cost = @shell_lubricant_5L.average_cost
      
      @pertamina_purchase_entry= @purchase_order.add_purchase_entry_item( @pertamina_lubricant_5L,  @new_pertamina_quantity,   @new_pertamina_price )
      @shell_purchase_entry = @purchase_order.add_purchase_entry_item( @shell_lubricant_5L,  @new_shell_quantity,   @new_shell_price )
      @initial_stock_entry_count = StockEntry.count      
      @initial_stock_mutations_count = StockMutation.count                                              
      @purchase_order.confirm_purchase( @admin)  
      
    end
    
    it 'should have been confirmed' do
      @purchase_order.is_confirmed?.should be_true 
    end
    
    it 'should not be double confirmed' do
      result  = @purchase_order.confirm_purchase( @admin)  
      result.should be_nil 
    end
    
    it 'should produce total price based on the given custom price'  do
      price = BigDecimal('0')
      price += @new_pertamina_quantity * @new_pertamina_price
      price += @new_shell_quantity * @new_shell_price
      
      price.should == @purchase_order.total_amount_to_be_paid
    end
    
    it 'should alter the ready item quantity' do
      @shell_lubricant_5L.reload
      @pertamina_lubricant_5L.reload
      
   
      
      (@pertamina_lubricant_5L.ready - @initial_pertamina_quantity) .should == @new_pertamina_quantity
      (@shell_lubricant_5L.ready - @initial_shell_quantity) .should == @new_shell_quantity
    end
    
    it 'should alter the average cost of the item' do
      new_pertamina_average_cost = BigDecimal('0')
      new_pertamina_average_cost += @initial_pertamina_quantity * @initial_pertamina_average_cost
      new_pertamina_average_cost += @new_pertamina_quantity * @new_pertamina_price
      @pertamina_lubricant_5L.reload
      
      new_pertamina_average_cost = new_pertamina_average_cost/(@new_pertamina_quantity + @initial_pertamina_quantity).to_f
   
      @pertamina_lubricant_5L.average_cost.to_i.should == new_pertamina_average_cost.to_i
      
      
      new_shell_average_cost = BigDecimal('0')
      new_shell_average_cost += @initial_shell_quantity * @initial_shell_average_cost
      new_shell_average_cost += @new_shell_quantity * @new_shell_price
      @shell_lubricant_5L.reload
      
      new_shell_average_cost = new_shell_average_cost/(@new_shell_quantity + @initial_shell_quantity).to_f
   
      @shell_lubricant_5L.average_cost.to_i.should == new_shell_average_cost.to_i
      
    end
    
    it 'should add more stock entry' do
      
      StockEntry.where(
        :entry_case =>STOCK_ENTRY_CASE[:purchase], 
        :item_id => @shell_lubricant_5L.id ,
        :source_document => @shell_purchase_entry.class.to_s,
        :source_document_id => @shell_purchase_entry.id
       ).count == 1 
       
       StockEntry.where(
         :entry_case =>STOCK_ENTRY_CASE[:purchase], 
         :item_id => @pertamina_lubricant_5L.id ,
         :source_document => @pertamina_purchase_entry.class.to_s,
         :source_document_id => @pertamina_purchase_entry.id
        ).count == 1
       
      final_stock_entry = StockEntry.count 
      (final_stock_entry -@initial_stock_entry_count).should == 2 
    end
    
    it 'should create stock mutation' do
      
      StockMutation.where(   
        :source_document_entry_id  =>  @shell_purchase_entry.id   ,
        :source_document_id  =>  @shell_purchase_entry.purchase_order_id  ,
        :source_document_entry     =>  @shell_purchase_entry.class.to_s,
        :source_document    =>  @shell_purchase_entry.purchase_order.class.to_s,
        :mutation_case      => MUTATION_CASE[:purchase_order],
        :mutation_status => MUTATION_STATUS[:addition],
        :item_id => @shell_purchase_entry.item_id
      ).count == 1
      
      StockMutation.where(   
        :source_document_entry_id  =>  @pertamina_purchase_entry.id   ,
        :source_document_id  =>  @pertamina_purchase_entry.purchase_order_id  ,
        :source_document_entry     =>  @pertamina_purchase_entry.class.to_s,
        :source_document    =>  @pertamina_purchase_entry.purchase_order.class.to_s,
        :mutation_case      => MUTATION_CASE[:purchase_order],
        :mutation_status => MUTATION_STATUS[:addition],
        :item_id => @pertamina_purchase_entry.item_id
      ).count == 1
      
      
      final_stock_mutations = StockMutation.count 
      (final_stock_mutations -@initial_stock_mutations_count).should == 2
      
    end
    
  end
   
  
  
     
end
