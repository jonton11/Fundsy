class CreateRewards < ActiveRecord::Migration # :nodoc:
  def change
    create_table :rewards do |t|
      t.integer :amount
      t.text :description
      t.references :campaign, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
