class DropBasicResources < ActiveRecord::Migration[5.0]
  def change
    drop_table :basic_resources
  end
end
