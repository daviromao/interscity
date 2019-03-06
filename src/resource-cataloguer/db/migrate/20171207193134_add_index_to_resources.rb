class AddIndexToResources < ActiveRecord::Migration[5.0]
  def change
    add_index :basic_resources, :uuid, :unique => true
    add_index :basic_resources, [:lat, :lon]
    add_index :capabilities, :name, :unique => true
  end
end
