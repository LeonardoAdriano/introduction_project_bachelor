class ChangeCourseNameFromPrivateToPublic < ActiveRecord::Migration[6.1]
  def change
    rename_column :courses, :private, :public
  end
end
