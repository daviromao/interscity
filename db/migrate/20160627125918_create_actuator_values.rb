class CreateActuatorValues < ActiveRecord::Migration[5.0]
  def change
    create_table :actuator_values do |t|
      t.belongs_to :platform_resource, index: true
      t.belongs_to :capability, index: true
      t.string :value
      t.timestamps
    end
  end
end
