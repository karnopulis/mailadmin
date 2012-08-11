class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t| 
      t.column :name, :string
      t.column :adress, :string 
      t.column :login, :string 
      t.column :pass, :string  
      t.timestamps
    end
    create_table :clients do |t|
     	t.column :name, :string 
	t.column :company, :string
 	t.column :phone, :string
	t.column :email, :string
	t.column :site_id, :integer
     	t.timestamps
    end
  end
end
