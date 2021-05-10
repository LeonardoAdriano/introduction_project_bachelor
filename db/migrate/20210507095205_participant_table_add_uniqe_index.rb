class ParticipantTableAddUniqeIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :participants,
    [:user_id, :course_id],
    :unique => true,
    :name => 'user_course_references_unique'
  end
end
