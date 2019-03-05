class DefineSensorAndActuatorDefaultValue < ActiveRecord::Migration[5.0]
  def change
    change_column :basic_resources, :sensor, :boolean, default: false
    change_column :basic_resources, :actuator, :boolean, default: false
  end
end
