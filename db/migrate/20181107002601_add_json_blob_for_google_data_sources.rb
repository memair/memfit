class AddJsonBlobForGoogleDataSources < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :google_data_sources, :jsonb
  end
end
