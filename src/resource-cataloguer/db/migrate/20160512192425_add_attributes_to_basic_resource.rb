class AddAttributesToBasicResource < ActiveRecord::Migration[5.0]
  def change
    add_column :basic_resources, :lat, :float
    add_column :basic_resources, :long, :float
    add_column :basic_resources, :status, :string
    add_column :basic_resources, :collect_interval, :integer
    add_column :basic_resources, :description, :text
    add_column :basic_resources, :uuid, :string
  end
end
