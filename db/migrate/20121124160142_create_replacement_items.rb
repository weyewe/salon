class CreateReplacementItems < ActiveRecord::Migration
  def change
    create_table :replacement_items do |t|
      t.integer :service_item_id 
      t.integer :item_id 

      t.timestamps
    end
  end
end
