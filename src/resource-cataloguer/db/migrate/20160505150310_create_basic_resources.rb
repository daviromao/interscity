class CreateBasicResources < ActiveRecord::Migration[5.0]
  def change
    create_table :basic_resources do |t|
      t.string :uri

      t.timestamps
    end
  end
end
