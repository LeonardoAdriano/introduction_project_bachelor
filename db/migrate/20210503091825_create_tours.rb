class CreateTours < ActiveRecord::Migration[6.1]
  def change
    create_table :tours do |t|
      t.string :name
      t.string :driver_name
      t.string :city

      t.timestamps
    end
  end
end
