class CreateWarehouses < ActiveRecord::Migration
  def change
    create_table :warehouses do |t|

      t.timestamps
    end
  end
end
