class CreateLastSensorValues < ActiveRecord::Migration[5.0]
  def change
    create_table :last_sensor_values do |t|
      t.string :value
      t.float :f_value
      t.datetime :date
      t.belongs_to :capability, index: true
      t.belongs_to :platform_resource, index: true
      
      t.timestamps
    end
  end
end
