class AddPostalCodeToBasicResources < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :postal_code, :string
  end
end
