class Api::V1::RewardController < ApplicationController
  
  def index
    rewards = current_user.rewards.select(:id, :amount, :status).all

    total_rewards = rewards.sum(:amount) if rewards.present? 
    json_response({
      rewards: rewards,
      total_rewards: total_rewards
    })
  end
end
