class CreateComponents < ActiveRecord::Migration[5.0]
  def change
    create_table :components do |t|
      t.string :uuid
      t.float :lat
      t.float :lon
      t.string :service_type
      t.string :status, null: false, default: "active"
      t.integer :collect_interval
      t.datetime :last_collection, null: false, default: Time.now
      t.text :capabilities
      t.text :last_collection
      t.text :description
      t.references :basic_resource
      t.timestamps null: false
    end
  end
end
