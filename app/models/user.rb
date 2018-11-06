class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:memair, :google_oauth2]

  def self.from_memair_omniauth(omniauth_info)
    data        = omniauth_info.info
    credentials = omniauth_info.credentials

    user = User.where(email: data['email']).first

    unless user
     user = User.create(
       email:    data['email'],
       password: Devise.friendly_token[0,20]
     )
    end

    user.memair_access_token = credentials['token']
    user.save
    user
  end

  def from_google_omniauth(omniauth_info)
    data        = omniauth_info.info
    credentials = omniauth_info.credentials

    self.google_uid = omniauth_info.uid

    self.google_name  = data.first_name + ' ' + data.last_name
    self.google_image = data.image
    self.google_email = data.email

    self.google_access_token            = credentials.token
    self.google_refresh_token           = credentials.refresh_token
    self.google_access_token_expires_at = Time.at(credentials.expires_at).utc

    self.save
    self
  end

  def valid_google_token?
    self.google_access_token_expires_at > (Time.now + 60.seconds)
  end

  def refresh_google_token!
    data = JSON.parse(request_token_from_google.body)
    update_attributes(
     google_access_token: data['access_token'],
     google_access_token_expires_at: Time.now + data['expires_in'].to_i.seconds
    )
  end

  def revoke_google_token!
    uri = URI('https://accounts.google.com/o/oauth2/revoke')
    params = { :token => self.google_refresh_token }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get(uri)
  end

  private

    def request_token_from_google
      params = {
        refresh_token: self.google_refresh_token,
        client_id:     ENV['GOOGLE_CLIENT_ID'],
        client_secret: ENV['GOOGLE_CLIENT_SECRET'],
        grant_type:    'refresh_token'
      }
      url = URI("https://www.googleapis.com/oauth2/v4/token")
      Net::HTTP.post_form(url, params)
    end
end
