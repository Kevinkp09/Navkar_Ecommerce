class Api::V1::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      render json: {message: "User registered successfully"}, status: :created 
    else
      render json: {error: user.errors.full_messages}, status: :unprocessable_entity
    end
  end
end
