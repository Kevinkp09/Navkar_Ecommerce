class Api::V1::OrdersController < ApplicationController
  before_action :set_order, only: [:update, :destroy]
  def create
    user = current_user
    order = user.orders.new(order_params)
    if order.save
      render json: { order: order, message: "Order successfully created." }, status: :created
    else
      render json: { error: order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @order.update(order_params)
      render json: { order: @order, message: "Order successfully updated." }, status: :ok
    else
      render json: { error: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @order.destroy
      render json: {message: "Order deleted successfully"}, status: :ok
    else
      render json: {error: @order.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private
  def set_order
    user = current_user
    @order = user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:status, :tracking_id, :total_price, :courier_id, product_ids: [])
  end
end
