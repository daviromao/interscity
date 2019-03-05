class CreateSensorValues < ActiveRecord::Migration[5.0]
  def change
    create_table :sensor_values do |t|
      t.string :value
      t.datetime :date
      t.belongs_to :capability, index: true
      t.belongs_to :platform_resource, index: true
      
      t.timestamps
    end
  end
end
