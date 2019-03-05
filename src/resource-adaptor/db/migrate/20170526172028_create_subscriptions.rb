class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.string :uuid
      t.string :url
      t.string :capabilities, array: true, default: []
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
