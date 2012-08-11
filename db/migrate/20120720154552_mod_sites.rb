class ModSites < ActiveRecord::Migration
  def change
	rename_column :sites, :current, :current_client
	add_column :sites, :current_order, :integer
  end
end
