class AddDeliveedFlagToClients < ActiveRecord::Migration
  def change
   add_column :clients, :delivered, :boolean, :default => 0
  end
end
