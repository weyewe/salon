class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name 
      
      t.boolean :is_deleted, :default => false 
      
      t.decimal :recommended_selling_price , :precision => 11, :scale => 2 , :default => 0  # 10^9 << max value
      
      t.integer :number_of_employee 
      
      t.decimal :commission_per_employee , :precision => 11, :scale => 2 , :default => 0
      
      t.timestamps
    end
  end
end
