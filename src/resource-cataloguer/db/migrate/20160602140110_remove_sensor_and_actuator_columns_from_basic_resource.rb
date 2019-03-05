class RemoveSensorAndActuatorColumnsFromBasicResource < ActiveRecord::Migration[5.0]
  def change
    change_table :basic_resources do |t|
      t.remove :sensor
      t.remove :actuator
    end
  end
end
