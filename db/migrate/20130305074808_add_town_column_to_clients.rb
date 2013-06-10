class AddTownColumnToClients < ActiveRecord::Migration
  def change
    add_column :clients, :town, :string
  end
end
