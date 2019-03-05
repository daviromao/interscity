class AddStateToBasicResources < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :state, :string
  end
end
