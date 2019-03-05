class ChangeLonField < ActiveRecord::Migration[5.0]
  def change
    rename_column :basic_resources, :long, :lon
  end
end
