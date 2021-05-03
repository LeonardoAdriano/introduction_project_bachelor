class CreateCourses < ActiveRecord::Migration[6.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.boolean :private
      t.date :valid_until
      t.date :accessible_until
      t.date :accessible_from

      t.timestamps
    end
  end
end
