class AddingLastPolledToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :retrieved_until, :date
  end
end
