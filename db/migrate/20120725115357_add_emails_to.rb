class AddEmailsTo < ActiveRecord::Migration
  def change
   add_column :sites, :reg_emails, :string
   add_column :sites, :orders_emails, :string

  end
end
