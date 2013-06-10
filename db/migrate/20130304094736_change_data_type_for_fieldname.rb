class ChangeDataTypeForFieldname < ActiveRecord::Migration
  def up
	change_column :orders, :xml, :text, :limit => 4294967295
  end

  def down
  end
end
