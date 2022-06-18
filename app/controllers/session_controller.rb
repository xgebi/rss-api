class SessionController < ApplicationController
  def authenticate
    @user = User.find_by(username: request.params[:username])
    if @user&.authenticate(request.params[:password])
      token = { id: @user[:id], username: @user[:username] }
      render json: { name: @user[:username], id: @user[:id], token: TokenService::encode(token) }
    else
      render json: {
        status: 401,
        error: "Could not authenticate your account"
      }
    end
  end

  private
  def session_params
    params.require(:user).permit(:username, :password)
  end
end
