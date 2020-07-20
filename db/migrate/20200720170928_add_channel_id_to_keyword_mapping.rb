class AddChannelIdToKeywordMapping < ActiveRecord::Migration[5.2]
  def change
    add_column :keyword_mappings, :channel_id, :string, null: false
  end
end
