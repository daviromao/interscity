class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.string :name
      t.string :uuid
      t.string :uri
      t.timestamps
    end

  end


end
