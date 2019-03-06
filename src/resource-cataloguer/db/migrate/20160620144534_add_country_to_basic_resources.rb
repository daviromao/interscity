class AddCountryToBasicResources < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :country, :string
  end
end
