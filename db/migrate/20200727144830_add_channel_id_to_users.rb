class AddChannelIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :channel_id, :string, null: false
  end
end
