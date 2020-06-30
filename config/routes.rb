Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post "/api/v1/signin" => "api/v1/user#authenticate"
  post "/api/v1/user" => "api/v1/user#create"
  post "/api/v1/user/:referral_token" => "api/v1/user#create_with_referral"
  post "/api/v1/invite" => "api/v1/user#invite_users"

  get "/api/v1/user" => "api/v1/user#show"
  get "/api/v1/referral_link" => "api/v1/user#referral_link"
  get "/api/v1/rewards" => "api/v1/reward#index"
  get "/api/v1/referred_users" => "api/v1/user#invited_users"

  root to: "api/v1/user#index"

end
