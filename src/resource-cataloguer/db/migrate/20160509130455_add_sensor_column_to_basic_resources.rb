class AddSensorColumnToBasicResources < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :sensor, :boolean
  end
end
