class AddValueFloatToSensorValues < ActiveRecord::Migration[5.0]
  def change
    add_column :sensor_values, :f_value, :float
  end
end
