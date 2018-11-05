class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def memair
    @user = User.from_memair_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = 'Successfully connected with Memair, now connect with Google Fit'

      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.memair_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def google_oauth2
    current_user.from_google_omniauth(request.env['omniauth.auth'])
    flash[:success] = 'Successfully connected with Google Fit'
    redirect_to root_path
  end
end
