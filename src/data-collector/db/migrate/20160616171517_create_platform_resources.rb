class CreatePlatformResources < ActiveRecord::Migration[5.0]
  def change
    create_table :platform_resources do |t|
      t.string :uri
      t.string :uuid
      t.string :status
      t.integer :collect_interval

      t.timestamps
    end
  end
end
