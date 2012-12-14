# Create Office  
# admin_role = Role.create :name => USER_ROLE[:admin]
# purchasing_role = Role.create :name => USER_ROLE[:purchasing]
# inventory_role = Role.create :name => USER_ROLE[:inventory]
# sales_role = Role.create :name => USER_ROLE[:sales]  
# mechanic_role = Role.create :name => USER_ROLE[:mechanic]

jakarta = Town.create(:name => "Jakarta")
lampung = Town.create :name => "Lampung"

admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 
# admin.add_role_if_not_exists( admin_role ) 
admin.reload

dixzell_company = Company.create :name => "Dixzell", :address => "Depan Citra 1", :phone => "54563659"
 
# Create Employee 

 
# these 2 are mechanics 
joko = Employee.create(   :name => "Joko"  )  
joni = Employee.create(   :name => "Joni" ) 

 
            
                        
# CREATE ITEM CATEGORY 
puts "Created the basic"
spare_part =  Category.create :name => "Spare Part" 
base_service_category =  ServiceCategory.create :name => "Service" 

puts "created the first A"
  body_part = spare_part.create_sub_category :name => "Body Part" 
    head_lamp = body_part.create_sub_category :name => "Head Lamp"
    radio_receiver = body_part.create_sub_category :name => "Radio Receiver"
    speaker = body_part.create_sub_category :name => "Speaker"
   
puts "created the first B"
  engine_spare_part = spare_part.create_sub_category :name => "Spare Part Mesin"
    piston =   engine_spare_part.create_sub_category :name => "Piston"
    valve =   engine_spare_part.create_sub_category :name => "Valve"
    piston =   engine_spare_part.create_sub_category :name => "Piston"
    lubricant = engine_spare_part.create_sub_category :name => "Lubricant"
    shock_breaker = engine_spare_part.create_sub_category :name => "Shock Breaker"

puts "Created the first C"
  undercarriage = spare_part.create_sub_category :name => "Undercarriage"   
    combustion_pipe =   undercarriage.create_sub_category :name => "Combustion Pipe"

puts "Create the last shit "                        
# Create VENDOR 
toyota_puri = Vendor.create :name => "Toyota Puri",
                    :contact_person => "Wilson",
                    :mobile => "08161437707"
puts "created the toyota puri"
bangjay = Vendor.create :name => "Bangjay", 
                        :contact_person => "Rudi",
                        :mobile => "0819 323 27 141"
                        
puts " about to create inventory item "
# Create Inventory Item 
shell_lubricant = Item.create_by_category(   lubricant, :name => "Shell Formula 1 Lubricant 5L") 
shell_lubricant_eceran = Item.create_by_category(  lubricant, :name => "[Eceran]Shell Formula 1 Lubricant 1L") 
pertamina_lubricant = Item.create_by_category( lubricant, :name => "Pertamina Top Gun 4L")
top_one_lubricant = Item.create_by_category(   lubricant , :name => "Top One Indomobil 5L")


puts "After creating inventory item "
# Stock the inventory Item, using initial migration  
shell_quantity = 30
shell_price_per_item  =  BigDecimal('400000')
StockMigration.create_item_migration(admin, shell_lubricant, shell_quantity,  shell_price_per_item) 
shell_lubricant.reload 

pertamina_quantity = 20
pertamina_price_per_item  =  BigDecimal('350000')
StockMigration.create_item_migration(admin, pertamina_lubricant, pertamina_quantity,  pertamina_price_per_item)
pertamina_lubricant.reload   


puts "After all the stock migration "
# create customer ( REGISTERED vehicle, it means )
willy = Customer.create :name => "Weyewe",
                    :contact_person => "Willy",
                    :town_id => jakarta.id 
                    
wilson = Customer.create :name => "Alfindo",
                    :contact_person => "Wilson Gozali" ,
                    :town_id => lampung.id 
                    
vios_b_1725_bad_params = {
  :id_code => "B1725BAD"
} 

vios_b_1725_bad  = willy.new_vehicle_registration( admin ,  vios_b_1725_bad_params )    


rush_b_1665_bsf_params = {
  :id_code => "B 1725Bsf"
}

rush_b_1665_bsf  = willy.new_vehicle_registration( admin ,  rush_b_1665_bsf_params )    

=begin
  Create the basic sales case 
  1. new customer come, with unregistered broken car 
  2. create sales order
  3. add service fee  
  
  many cases of sales order
  1. only purchasing things   # not our target market 
  # if there is service involved, maintenance must be included
  2. purchase for maintenance purpose 
  3. both of them mixed altogether 
  
  # Registered Customer == can be given credit 
  
  
=end    

##################################################################
###  Simplest case: creating one (only purchase, no maintenance, purely retail)
###  no indent sales 
###  the purchase price is not deduced from the price books. entered 
###  PRICE BOOK? Later.. First priority: make the sales order a reality. 
##################################################################
customer = nil
vehicle = nil 
sales_order=  SalesOrder.create_sales_order( admin, customer )  

shell_purchase_quantity = 5
shell_purchase_price = BigDecimal('600000')
shell_lubricant_sales_entry = sales_order.add_sales_entry_item(shell_lubricant, 
                                                            shell_purchase_quantity, 
                                                            shell_purchase_price ) 

pertamina_purchase_quantity = 1
pertamina_purchase_price = BigDecimal('540000')
pertamina_lubricant_sales_entry = sales_order.add_sales_entry_item(pertamina_lubricant, 
                                                            pertamina_purchase_quantity, 
                                                            pertamina_purchase_price )
                                    

puts "Total sales entries: #{sales_order.active_sales_entries.count }"   

sales_order.delete_sales_entry( pertamina_lubricant_sales_entry )    
sales_order.reload 
puts "Total sales entries: #{sales_order.active_sales_entries.count }"   


sales_order.confirm_sales( admin ) # will create stock entry, update the item's stock summary 




##################################################################
###  Case 2: customer subscribed to the sales 
###  no indent sales 
###  the purchase price is not deduced from the price books.  
###  PRICE BOOK? Later.. First priority: make the sales order a reality. 
##################################################################

customer = willy
vehicle = nil 
sales_order=  SalesOrder.create_sales_order( admin, customer  )  

shell_purchase_quantity = 5
shell_purchase_price = BigDecimal('600000')
shell_lubricant_sales_entry = sales_order.add_sales_entry_item(shell_lubricant, 
                                                            shell_purchase_quantity, 
                                                            shell_purchase_price ) 

pertamina_purchase_quantity = 1
pertamina_purchase_price = BigDecimal('540000')
pertamina_lubricant_sales_entry = sales_order.add_sales_entry_item(pertamina_lubricant, 
                                                            pertamina_purchase_quantity, 
                                                            pertamina_purchase_price )


puts "Total sales entries: #{sales_order.active_sales_entries.count }"   

sales_order.delete_sales_entry( pertamina_lubricant_sales_entry )    
sales_order.reload 
puts "Total sales entries: #{sales_order.active_sales_entries.count }"   


sales_order.confirm_sales( admin ) # will create stock entry, update the item's stock summary

total_willy_sales_order = customer.sales_orders.count 
puts "Total willy sales order: #{total_willy_sales_order}"
                  
 
##################################################################
###  Case 3: customer + vehicle subscribed to sales  
###  no indent sales 
###  the purchase price is not deduced from the price books.  
###  PRICE BOOK? Later.. First priority: make the sales order a reality. 
##################################################################


customer = willy
vehicle = rush_b_1665_bsf 
sales_order=  SalesOrder.create_sales_order( admin, customer )  

shell_purchase_quantity = 5
shell_purchase_price = BigDecimal('600000')
shell_lubricant_sales_entry = sales_order.add_sales_entry_item(shell_lubricant, 
                                                            shell_purchase_quantity, 
                                                            shell_purchase_price ) 

pertamina_purchase_quantity = 1
pertamina_purchase_price = BigDecimal('540000')
pertamina_lubricant_sales_entry = sales_order.add_sales_entry_item(pertamina_lubricant, 
                                                            pertamina_purchase_quantity, 
                                                            pertamina_purchase_price )

puts "Total sales entries: #{sales_order.active_sales_entries.count }"   

sales_order.delete_sales_entry( pertamina_lubricant_sales_entry )    
sales_order.reload 
puts "Total sales entries: #{sales_order.active_sales_entries.count }"   

sales_order.confirm_sales( admin ) # will create stock entry, update the item's stock summary

total_willy_sales_order = customer.sales_orders.count 
puts "Total willy sales order: #{total_willy_sales_order}"
puts "Total rush_b_1665_bsf sales order: #{vehicle.sales_orders.count }"


=begin
  CREATING SERVICES 
=end


puts "Before creating services"
lubricant_replacement = Service.create :name => "Lubricant Replacement"
lubricant_replacement.set_price( BigDecimal('100000'))
tire_replacement = Service.create :name => "Tire replacement"
tire_replacement.set_price( BigDecimal("200000"))



customer = willy
vehicle = rush_b_1665_bsf 
sales_order =  SalesOrder.create_sales_order( admin, customer )  

puts "About to create service"
lubricant_replacement_sales_entry   = sales_order.add_sales_entry_service(lubricant_replacement, BigDecimal("40000")  ) 

# lubricant_replacement_sales_entry.service_item.add_item( item_list ) 

tire_replacement_sales_entry  = sales_order.add_sales_entry_service(tire_replacement , BigDecimal('500000'))

puts "Done adding service"

lubricant_replacement_sales_entry.add_employees( [joko] )
tire_replacement_sales_entry.add_employees( [joni] ) 
 
sales_order.confirm_sales( admin ) # will create stock entry, update the item's stock summary

total_willy_sales_order = customer.sales_orders.count 
puts "Total willy sales order: #{total_willy_sales_order}"
puts "Total rush_b_1665_bsf sales order: #{vehicle.sales_orders.count }"


=begin
admin_user = User.first
admin_role = Role.find_by_name("admin")
admin_user.role_id = admin_role.id
admin_user.save
=end
