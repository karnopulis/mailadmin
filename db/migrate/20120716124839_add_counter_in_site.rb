class AddCounterInSite < ActiveRecord::Migration
  def change
    add_column :sites, :current, :integer 
  end
end
