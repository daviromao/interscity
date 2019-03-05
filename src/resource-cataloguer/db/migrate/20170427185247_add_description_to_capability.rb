class AddDescriptionToCapability < ActiveRecord::Migration[5.0]
  def change
    add_column :capabilities, :description, :text
  end
end
