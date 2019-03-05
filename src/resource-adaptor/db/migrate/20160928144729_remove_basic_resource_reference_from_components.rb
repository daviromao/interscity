class RemoveBasicResourceReferenceFromComponents < ActiveRecord::Migration
  def change
    remove_column :components, :basic_resource_id
  end
end
