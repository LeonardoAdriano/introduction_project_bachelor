class AddProducerToProduct < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :producer, foreign_key: true
  end
end
