class AddManagerColumnToClients < ActiveRecord::Migration
  def change
    add_column :clients, :manager, :string
  end
end
