class FixColumnName < ActiveRecord::Migration
  def change
   rename_column :sites, :adress, :address   
  end
end
