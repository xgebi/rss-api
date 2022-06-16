class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def current_user
    if request.headers['Authorization']
      token = request.headers['Authorization'].split(' ')[1]
      if token
        token_service = TokenService.new
        payload = token_service.decode(token)
        byebug
        @current_user ||= User.find_by(id: payload[0]['id'])
      end
    end
  end

  def logged_in?
    current_user != nil
  end

  def authenticate_user!
    head :unauthorized unless logged_in?
  end
end
