class CreateBasicResources < ActiveRecord::Migration
  def change
    create_table :basic_resources do |t|
      t.integer :uuid
      t.string :name
      t.string :model
      t.string :maker
      t.string :url
      t.timestamps null: false
    end
  end
end
