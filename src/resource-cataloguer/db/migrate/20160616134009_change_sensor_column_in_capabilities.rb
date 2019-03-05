class ChangeSensorColumnInCapabilities < ActiveRecord::Migration[5.0]
  def change
    change_table :capabilities do |t|
      t.remove :sensor
      t.integer :function
    end
  end
end
