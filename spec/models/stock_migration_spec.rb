require 'spec_helper'

describe StockMigration do
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
  end 
  
  
  context "stock migration" do
    # precondition
    before(:each) do 
      @migration_quantity = 5 
      @migration_price = BigDecimal('40000')
      @initial_item_ready_quantity = @pertamina_lubricant_5L.ready
    end
    it 'should only allowed to be done once' do
      stock_entry = StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
            @migration_quantity,  @migration_price)  
      stock_entry.should be_valid  
    end
    
    context "after stock migration, success case" do 
      before(:each) do
        @stock_entry = StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
              @migration_quantity,  @migration_price)  
      end
      
      it 'should not be done if there has been any other stock mutation on item' do
        
        stock_entry = StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
              @migration_quantity,  @migration_price)  
        stock_entry.should be_nil  
      end

      # post condition 
      it 'should create one stock mutation' do
        @stock_entry.stock_mutations.count.should == 1 
        
        stock_mutation = @stock_entry.stock_mutations.first 
        stock_mutation.quantity.should == @migration_quantity
        
        stock_migration = StockMigration.first
        stock_mutation.quantity                .should ==   @migration_quantity
        stock_mutation.stock_entry_id          .should ==   @stock_entry.id 
        stock_mutation.creator_id              .should ==   @admin.id
        stock_mutation.source_document_entry_id.should ==   stock_migration.id
        stock_mutation.source_document_id      .should ==   stock_migration.id
        stock_mutation.source_document_entry   .should ==   stock_migration.class.to_s
        stock_mutation.source_document         .should ==   stock_migration.class.to_s
        stock_mutation.mutation_case           .should ==   MUTATION_CASE[:stock_migration]
        stock_mutation.mutation_status         .should ==   MUTATION_STATUS[:addition]
        stock_mutation.item_id                 .should ==   @pertamina_lubricant_5L.id
        
      end
      
      it 'should add item quantity, change the average price' do
        @pertamina_lubricant_5L.reload
        
        (@pertamina_lubricant_5L.ready - @initial_item_ready_quantity).should == @migration_quantity
      end
      
      it 'should produce StockMigration stock entry' do
        @stock_entry.entry_case. should == STOCK_ENTRY_CASE[:initial_migration]
        @stock_entry.source_document.should == StockMigration.to_s
      end
      
      it 'should set the average price of the item' do
        @pertamina_lubricant_5L.average_cost.should == @migration_price
      end
    end  # context success case, post conditions 
    
    
    # post condition, fail case 
    context "after stock migration, fail case" do 
      it 'should not allow quantity <= 0 ' do
        stock_entry = StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
              0,  @migration_price)
        
        stock_entry.should_not be_valid 
      end
      
      it 'should not allow base price <= 0 '  do
        stock_entry = StockMigration.create_item_migration(@admin, @pertamina_lubricant_5L, 
              5,  BigDecimal('0'))
        
        stock_entry.should_not be_valid
        stock_entry.errors.messages.length == 1
      end
    end
    
  end
  
end
 