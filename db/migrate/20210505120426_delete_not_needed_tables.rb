class DeleteNotNeededTables < ActiveRecord::Migration[6.1]
  def change
    drop_table :tours
    drop_table :articles
    drop_table :products
    drop_table :producers
  end
end
