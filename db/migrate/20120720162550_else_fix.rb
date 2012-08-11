class ElseFix < ActiveRecord::Migration
	def change
    change_column :sites, :current_order, :integer, :default => 0
    change_column :sites, :current_client, :integer, :default => 0

  end

end
