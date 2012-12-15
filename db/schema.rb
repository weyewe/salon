# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121214053141) do

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "compatibilities", :force => true do |t|
    t.integer  "service_component_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.boolean  "is_deleted",           :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "conversion_entries", :force => true do |t|
    t.integer  "stock_conversion_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.integer  "entry_status",        :default => 1
    t.boolean  "is_deleted",          :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "convert_stocks", :force => true do |t|
    t.integer  "stock_conversion_id"
    t.integer  "creator_id"
    t.integer  "source_quantity",     :default => 0
    t.integer  "year"
    t.integer  "month"
    t.boolean  "is_deleted",          :default => false
    t.integer  "deleter_id"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "office_address"
    t.text     "delivery_address"
    t.integer  "town_id"
    t.boolean  "is_deleted",       :default => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  create_table "employees", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "mobile_phone"
    t.text     "address"
    t.integer  "creator_id"
    t.integer  "year"
    t.integer  "month"
    t.boolean  "is_deleted",   :default => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "exchange_scrap_items", :force => true do |t|
    t.integer  "creator_id"
    t.string   "code"
    t.integer  "item_id"
    t.integer  "quantity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "items", :force => true do |t|
    t.integer  "creator_id"
    t.integer  "ready",                                                    :default => 0
    t.integer  "scrap",                                                    :default => 0
    t.integer  "pending_return",                                           :default => 0
    t.string   "name"
    t.integer  "category_id"
    t.decimal  "average_cost",              :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "recommended_selling_price", :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "is_deleted",                                               :default => false
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  create_table "maintenances", :force => true do |t|
    t.integer  "sales_order_id"
    t.integer  "vehicle_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "purchase_entries", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.decimal  "price_per_piece",      :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "total_purchase_price", :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "is_deleted",                                          :default => false
    t.integer  "sales_order_id"
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  create_table "purchase_orders", :force => true do |t|
    t.integer  "vendor_id"
    t.integer  "creator_id"
    t.string   "code"
    t.integer  "year"
    t.integer  "month"
    t.boolean  "is_deleted",         :default => false
    t.boolean  "is_confirmed",       :default => false
    t.integer  "confirmator_id"
    t.boolean  "is_paid",            :default => false
    t.integer  "paid_declarator_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "purchase_returns", :force => true do |t|
    t.integer  "creator_id"
    t.string   "code"
    t.integer  "item_id"
    t.integer  "quantity"
    t.integer  "purchase_order_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "replacement_items", :force => true do |t|
    t.integer  "service_item_id"
    t.integer  "item_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "title",       :null => false
    t.text     "description", :null => false
    t.text     "the_role",    :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "sales_entries", :force => true do |t|
    t.integer  "entry_id"
    t.integer  "entry_case",                                             :default => 2
    t.integer  "quantity"
    t.integer  "maintenance_id"
    t.decimal  "selling_price_per_piece", :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "total_sales_price",       :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "is_deleted",                                             :default => false
    t.integer  "sales_order_id"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
  end

  create_table "sales_orders", :force => true do |t|
    t.string   "code"
    t.integer  "creator_id"
    t.boolean  "is_registered_customer", :default => false
    t.integer  "customer_id"
    t.boolean  "is_registered_vehicle",  :default => false
    t.integer  "vehicle_id"
    t.integer  "year"
    t.integer  "month"
    t.boolean  "is_deleted",             :default => false
    t.integer  "deleter_id"
    t.boolean  "is_confirmed",           :default => false
    t.integer  "confirmator_id"
    t.datetime "confirmed_datetime"
    t.boolean  "is_paid",                :default => false
    t.integer  "paid_declarator_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "sales_return_entries", :force => true do |t|
    t.integer  "sales_entry_id"
    t.integer  "sales_return_id"
    t.integer  "quantity"
    t.decimal  "reimburse_price_per_piece", :precision => 11, :scale => 2, :default => 0.0
    t.decimal  "total_reimburse_price",     :precision => 11, :scale => 2, :default => 0.0
    t.boolean  "is_deleted",                                               :default => false
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  create_table "sales_returns", :force => true do |t|
    t.integer  "sales_order_id"
    t.string   "code"
    t.integer  "creator_id"
    t.integer  "customer_id"
    t.integer  "year"
    t.integer  "month"
    t.boolean  "is_deleted",                                        :default => false
    t.integer  "deleter_id"
    t.boolean  "is_confirmed",                                      :default => false
    t.integer  "confirmator_id"
    t.datetime "confirmed_datetime"
    t.decimal  "admin_fee",          :precision => 11, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
  end

  create_table "scrap_items", :force => true do |t|
    t.integer  "creator_id"
    t.string   "code"
    t.integer  "item_id"
    t.integer  "quantity"
    t.boolean  "is_finished",        :default => false
    t.integer  "exchanged_quantity", :default => 0
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "service_categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "service_components", :force => true do |t|
    t.integer  "service_id"
    t.string   "name"
    t.boolean  "is_deleted", :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "service_items", :force => true do |t|
    t.integer  "service_id"
    t.integer  "sales_entry_id"
    t.integer  "vehicle_id"
    t.boolean  "is_deleted",                                             :default => false
    t.boolean  "is_confirmed",                                           :default => false
    t.decimal  "commission_per_employee", :precision => 11, :scale => 2, :default => 0.0
    t.datetime "confirmed_datetime"
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
  end

  create_table "service_subcriptions", :force => true do |t|
    t.integer  "service_item_id"
    t.integer  "employee_id"
    t.integer  "is_active",       :default => 0
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.integer  "service_category_id"
    t.boolean  "is_deleted",                                               :default => false
    t.decimal  "recommended_selling_price", :precision => 11, :scale => 2, :default => 0.0
    t.integer  "number_of_employee"
    t.decimal  "commission_per_employee",   :precision => 11, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                                  :null => false
    t.datetime "updated_at",                                                                  :null => false
  end

  create_table "stock_adjustments", :force => true do |t|
    t.integer  "creator_id"
    t.string   "code"
    t.integer  "item_id"
    t.integer  "ready_quantity"
    t.integer  "physical_quantity"
    t.integer  "adjustment_quantity"
    t.integer  "adjustment_case"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "stock_conversions", :force => true do |t|
    t.string   "code"
    t.integer  "conversion_status", :default => 1
    t.boolean  "is_deleted",        :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  create_table "stock_entries", :force => true do |t|
    t.integer  "is_addition",                                         :default => 1
    t.integer  "creator_id"
    t.integer  "source_document_id"
    t.string   "source_document"
    t.integer  "entry_case"
    t.integer  "quantity"
    t.integer  "used_quantity",                                       :default => 0
    t.integer  "scrapped_quantity",                                   :default => 0
    t.integer  "item_id"
    t.boolean  "is_finished",                                         :default => false
    t.decimal  "base_price_per_piece", :precision => 12, :scale => 2, :default => 0.0
    t.datetime "created_at",                                                             :null => false
    t.datetime "updated_at",                                                             :null => false
  end

  create_table "stock_migrations", :force => true do |t|
    t.string   "code"
    t.boolean  "is_deleted", :default => false
    t.integer  "year"
    t.integer  "month"
    t.integer  "item_id"
    t.integer  "creator_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "stock_mutations", :force => true do |t|
    t.integer  "quantity"
    t.integer  "scrap_item_id"
    t.integer  "stock_entry_id"
    t.integer  "creator_id"
    t.integer  "source_document_id"
    t.string   "source_document_entry"
    t.integer  "source_document_entry_id"
    t.string   "source_document"
    t.integer  "mutation_case"
    t.integer  "mutation_status",          :default => 1
    t.integer  "item_status",              :default => 1
    t.integer  "item_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "towns", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.string   "name"
    t.string   "username"
    t.string   "login"
    t.integer  "is_main_user",           :default => 0
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vehicles", :force => true do |t|
    t.boolean  "is_customer_registered", :default => false
    t.string   "id_code"
    t.integer  "customer_id"
    t.boolean  "is_deleted",             :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "vendors", :force => true do |t|
    t.string   "name"
    t.string   "contact_person"
    t.string   "phone"
    t.string   "mobile"
    t.string   "email"
    t.string   "bbm_pin"
    t.text     "address"
    t.boolean  "is_deleted",     :default => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "warehouses", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
