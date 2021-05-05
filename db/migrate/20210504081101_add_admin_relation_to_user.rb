class AddAdminRelationToUser < ActiveRecord::Migration[6.1]
  def change
    add_reference :courses, :user, foreign_key: true
  end
end
