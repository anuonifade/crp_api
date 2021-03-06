class Api::V1::UserController < ApplicationController
  skip_before_action :authorize_request, only: [:create, :index, :authenticate]

  def index
    redirect_to '/api-docs'
  end

  def create
    # Registers user with or without referral
    user_data = user_params.merge({
      'referral_token' => SecureRandom.alphanumeric(16)
    })
    if params[:referral_token].present?
      @referral = find_referral(params[:referral_token])
      user = @referral.users.create(user_data)
    else
      user = User.create(user_data)
    end

    if user.persisted?
      token = AuthenticateUser.new(user.email, user.password).call
      response = { message: Message.account_created, auth_token: token }
      if params[:referral_token].present?
        reward = user.rewards.create(amount: 10.00)
        response['reward'] = reward.amount
        reward_referral
      end
      json_response(response, :created)
    end
  end

  def authenticate
    # Authenticate User
    token = AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
    json_response(auth_token: token)
  end

  def invite_users
    # Send invitation to users by scheduling with sidekiq worker.
    SendMailWorker.perform_async(params[:emails])
    json_response({message: 'Emails has been sent successfully'})
  end

  def update
    # Update user information
    current_user.update_attributes(
      first_name: user_params[:first_name],
      last_name: user_params[:last_name],
      email: user_params[:email]
    )
    response = {
      first_name: current_user[:first_name],
      last_name: current_user[:last_name],
      email: current_user[:email]
    }
    json_response({ user: response })
  end

  def show
    # Fetch  user information
    response = {
      first_name: current_user[:first_name],
      last_name: current_user[:last_name],
      email: current_user[:email]
    }
    json_response({user: response})
  end

  def referral_link
    # Fetch referral link to share with others
    referral_token = User.find(current_user.id).referral_token
    json_response({referral_link: "#{api_v1_create_user_path}/#{referral_token}"})
  end

  def invited_users
    # User can get all the users they invited 
    # And registered successfully
    @invited_users = current_user.users.select(:id, :first_name, :last_name, :email).all
    json_response({invited_users: @invited_users})
  end

  private

  def referral_count
    @referral.referral_count
  end

  def reward_referral
    # Update the referral count and when it is 5
    # Reward the user with $10 
    # and reset referral count back to 0
    update_referral_count
    if @referral.referral_count == 5
      @referral.rewards.create(amount: 10.00)
      reset_referral_count
    end
  end

  def update_referral_count
    # Increase the referral count by 1
    # when user registers with a referral
    @referral.update_attributes(referral_count: referral_count + 1)
  end

  def reset_referral_count
    # Reset referral count to 0 after rewarding user
    @referral.update_attributes(referral_count: 0)
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :referral_token)
  end

  def auth_params
    params.permit(:email, :password)
  end

  def find_referral(referral_token)
    User.find_by(referral_token: referral_token)
  end
end
