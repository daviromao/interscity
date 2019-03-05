class Capabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :capabilities do |t|
      t.string :name
      t.boolean :sensor
    end

    create_table :basic_resources_capabilities, id: false do |t|
      t.belongs_to :basic_resource, index: true
      t.belongs_to :capability, index: true
    end
  end
end
