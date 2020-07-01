class Api::V1::UserController < ApplicationController
  include Response
  include ExceptionHandler
  skip_before_action :authorize_request, only: [:create, :index, :authenticate]

  def index
    redirect_to '/api-docs'
  end

  def create
    user_data = user_params.merge({
      'referral_token' => SecureRandom.alphanumeric(16)
    })
    if params[:referral_token].present?
      referral = find_referral(params[:referral_token])
      user = referral.user.create(user_data)
    else
      user = User.create(user_data)
    end

    if user.persisted?
      token = AuthenticateUser.new(user.email, user.password).call
      response = { message: Message.account_created, auth_token: token }
      json_response(response, :created)
    end
  end

  def authenticate
    token = AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    json_response(auth_token: token)
  end

  def invite_users

  end

  def show
  end

  def referral_link

  end

  def invited_users
    binding.pry
    @invited_users = current_user.users.all
    json_response(@invited_users)
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :referral_token)
  end

  def auth_params
    params.permit(:email, :password)
  end

  def find_referral(referral_token)
    User.find_by(referral_token: referral_token)
  end

  def authorize
    user_id = JsonWebToken.decode()
  end
end
