class AddActuatorColumnToBasicResources < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :actuator, :boolean
  end
end
