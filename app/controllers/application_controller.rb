class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  def current_user
    return unless request.headers['Authorization']

    token = request.headers['Authorization'].split(' ')[1]
    return unless token

    token_service = TokenService.new
    payload = token_service.decode(token)
    @current_user ||= User.find_by(id: payload[0]['data']['id']) # TODO: this shall be redone a bit
  end

  def logged_in?
    current_user != nil
  end

  def authenticate_user!
    head :unauthorized unless logged_in?
  end
end
