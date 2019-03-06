class AddNeighborhoodToBasicResources < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :neighborhood, :string
  end
end
