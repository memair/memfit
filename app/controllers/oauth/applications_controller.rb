class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_action :authenticate_user!

  def index
    @applications = current_user.oauth_applications
  end

  def create
    params = application_params
    params['scopes'] = params[:checkbox_scopes].nil? ? '' : params[:checkbox_scopes].keys.join(" ")
    params.delete(:checkbox_scopes)
    @application = Doorkeeper::Application.new(params)
    @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end

  def update
    params = application_params
    params['scopes'] = params[:checkbox_scopes].nil? ? '' : params[:checkbox_scopes].keys.join(" ")
    params.delete(:checkbox_scopes)
    if @application.update(params)
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_url(@application)
    else
      render :new
    end
  end
  private

    def application_params
      params.require(:doorkeeper_application).permit(:name, :redirect_uri, :scopes, checkbox_scopes: [Doorkeeper.configuration.scopes.to_a])
    end
end
