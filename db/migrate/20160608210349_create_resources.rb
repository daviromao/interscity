class CreateResources < ActiveRecord::Migration[5.0]

  def change
    create_table :resources do |t|
      t.string :name
      t.string :uuid
      t.string :uri
      t.timestamps
    end

    create_table :capabilities do |t|
      t.string :name
      t.timestamps
    end

    create_table :actuator_values do |t|
      t.belongs_to :resource, index: true
      t.belongs_to :capability, index: true
      t.string :value
      t.timestamps
    end

    create_table :has_capabilities do |t|
      t.belongs_to :resource, index: true
      t.belongs_to :capability, index: true
      t.timestamps
    end

  end
end
