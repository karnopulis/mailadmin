class AddOrders < ActiveRecord::Migration
  def change 
	create_table :orders do |t|
	t.column :number, :string
	t.column :site_id, :integer
        t.column :user_id, :integer
        t.column :xml, :text
     	t.timestamps
    end

  end 
end
