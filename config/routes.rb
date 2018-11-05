Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get "/auth/:action/callback", controller: "authentications", constraints: { action: /memair|google_oauth2/ }
  end

  root 'static_pages#home'
end
