class AddTxnIdToPledges < ActiveRecord::Migration
  def change
    add_column :pledges, :txn_id, :string
  end
end
