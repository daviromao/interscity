class CreateIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :capabilities, :name, unique: true
    add_index :platform_resources, :uuid, unique: true
    add_index :platform_resource_capabilities,
        [:platform_resource_id, :capability_id], unique: true,
        name: 'index_platform_resource_capabilities'
  end
end
