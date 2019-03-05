class AddCityToBasicResources < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :city, :string
  end
end
