class AddTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :memair_access_token, :string
    add_column :users, :google_uid, :string
    add_column :users, :google_name, :string
    add_column :users, :google_image, :text
    add_column :users, :google_email, :string
    add_column :users, :google_access_token, :string
    add_column :users, :google_access_token_expires_at, :datetime
    add_column :users, :google_refresh_token, :string
  end
end
