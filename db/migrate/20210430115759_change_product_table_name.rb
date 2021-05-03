class ChangeProductTableName < ActiveRecord::Migration[6.1]
  def change
    add_column :articles , :pages, :integer
  end
end
