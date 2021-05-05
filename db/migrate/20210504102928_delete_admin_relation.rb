class DeleteAdminRelation < ActiveRecord::Migration[6.1]
  def change
    remove_column :courses, :user_id
  end
end
