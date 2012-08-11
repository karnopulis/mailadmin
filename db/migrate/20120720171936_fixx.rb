class Fixx < ActiveRecord::Migration
  def change
	rename_column :orders, :user_id, :client_id
  end
end
