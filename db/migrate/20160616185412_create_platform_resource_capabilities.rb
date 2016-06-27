class CreatePlatformResourceCapabilities < ActiveRecord::Migration[5.0]
  def change
    create_table :platform_resource_capabilities do |t|
      t.belongs_to :capability, index: true
      t.belongs_to :platform_resource, index: true
      t.timestamps
    end
  end
end
