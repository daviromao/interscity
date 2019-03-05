class DropBasicResources < ActiveRecord::Migration
  def change
    drop_table :basic_resources
  end
end
