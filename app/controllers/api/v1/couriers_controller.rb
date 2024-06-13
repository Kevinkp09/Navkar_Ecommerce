class Api::V1::CouriersController < ApplicationController
  before_action :set_courier, only: [:update, :destroy]
  def index
    couriers = Courier.all
    if couriers
      render json: {couriers: couriers, message: "Courier has been fetched successfully"}, status: :ok
    else
      render json: {error: courier.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def create
    courier = Courier.new(courier_params)
    if courier.save
      render json: {courier: courier, message: "Courier created successfully"}, status: :created
    else
      render json: {error: courier.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @courier.update(courier_params)
      render json: {courier: @courier, message: "Courier updated successfully"}, status: :ok
    else
      render json: {error: @courier.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @courier.destroy
      render json: {message: "Courier deleted successfully"}, status: :ok
    else
      render json: {error: @courier.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def courier_params
    params.require(:courier).permit(:name, :website)
  end

  def set_courier
    @courier = Courier.find(params[:id])
    render json: { message: 'Courier not found' }, status: :not_found unless @courier
  end
end
