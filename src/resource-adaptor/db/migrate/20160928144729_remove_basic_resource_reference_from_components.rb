class RemoveBasicResourceReferenceFromComponents < ActiveRecord::Migration[5.0]
  def change
    remove_column :components, :basic_resource_id
  end
end
