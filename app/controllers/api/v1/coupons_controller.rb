class Api::V1::CouponsController < ApplicationController
  before_action :set_coupon, only: [:update, :destroy]
  before_action :authorize_admin
  def index
    coupons = Coupon.all
    render json: {coupons: coupons}, status: :ok
  end

  def create
    coupon = Coupon.new(coupon_params)
    if coupon.save
      render json: {message: "Coupon created successfully"}, status: :created
    else
      render json: {error: coupon.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @coupon.update(coupon_params)
      render json: {message: "Coupon updated successfully"}, status: :ok
    else
      render json: {error: @coupon.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @coupon.destroy
      render json: {message: "Coupon deleted successfully"}, status: :ok
    else
      render json: {error: @coupon.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def coupon_params
    params.require(:coupon).permit(:code, :discount, :amount)
  end

  def set_coupon
    @coupon = Coupon.find(params[:id])
  end

  def authorize_admin
    unless admin?
      render json: { error: "You are not authorized to perform this action" }, status: :unauthorized
    end
  end
end
