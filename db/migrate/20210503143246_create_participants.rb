class CreateParticipants < ActiveRecord::Migration[6.1]
  def change
    create_table :participants do |t|
      t.boolean :accepts

      t.timestamps
    end
  end
end
