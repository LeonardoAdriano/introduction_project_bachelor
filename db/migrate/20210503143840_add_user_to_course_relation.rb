class AddUserToCourseRelation < ActiveRecord::Migration[6.1]
  def change
    add_reference :participants, :user, foreign_key: true
    add_reference :participants, :course, foreign_key: true
  end
end
