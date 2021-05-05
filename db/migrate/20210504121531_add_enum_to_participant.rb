class AddEnumToParticipant < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
        ALTER TABLE participants ADD member_type TEXT CHECK( member_Type in ('admin', 'participant'));
    SQL
  end

  def down
    remove_column :participants, :member_type
  end
end
