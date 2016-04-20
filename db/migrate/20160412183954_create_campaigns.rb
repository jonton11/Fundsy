class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :title
      t.integer :goal
      t.text :body
      t.datetime :end_date

      t.timestamps null: false
    end
  end
end
