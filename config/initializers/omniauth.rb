Rails.application.config.middleware.use OmniAuth::Builder do
  provider :memair, ENV['MEMAIR_CLIENT_ID'], ENV['MEMAIR_CLIENT_SECRET'], scope: 'biometric_write digital_activity_write location_write physical_activity_write'
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {scope: 'email, profile, https://www.googleapis.com/auth/fitness.activity.read', access_type: 'offline'}
end
