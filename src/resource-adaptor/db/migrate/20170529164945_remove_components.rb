class RemoveComponents < ActiveRecord::Migration[5.0]
  def change
    drop_table :components
  end
end
