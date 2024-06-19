# app/controllers/api/v1/payments_controller.rb
class Api::V1::PaymentsController < ApplicationController
  before_action :find_order, only: [:create, :callback]

  def create
    if @order.present?
      amount = (@order.discounted_price || @order.total_price).to_i * 100
      razorpay_order = Razorpay::Order.create(amount: amount, currency: 'INR')

      if razorpay_order.present? && razorpay_order.attributes['id'].present?
        payment = @order.build_payment(
          razorpay_order_id: razorpay_order.attributes['id'],
          amount: amount / 100.0,
          currency: 'INR',
          status: 'pending'
        )
        if payment.save
          render json: {
            message: "Payment is initiated",
            data: {
              order: @order,
              payment: payment,
              razorpay_order_id: razorpay_order.attributes['id'],
              amount: amount
            }
          }, status: :created
        else
          render json: { error: payment.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { message: "Failed to create order with Razorpay" }, status: :unprocessable_entity
      end
    else
      render json: { error: "Order not found" }, status: :not_found
    end
  end

  def callback
    order_id = params["order_id"]
    payment_id = params["payment_id"]
    razorpay_order = Razorpay::Order.fetch(order_id)

    if razorpay_order.attributes['status'] == 'paid'
      @payment = Payment.find_by(razorpay_order_id: order_id)
      if @payment.present?
        @payment.update(status: 'paid', razorpay_payment_id: payment_id)
        @order = @payment.order
        @order.update(status: 'transit')  # Update the order status upon successful payment
        render json: { message: "Payment is done successfully", data: { order: @order, payment: @payment } }, status: :ok
      else
        render json: { message: "Payment not found" }, status: :not_found
      end
    else
      render json: { message: "Payment failed, please try again" }, status: :unprocessable_entity
    end
  end

  private

  def find_order
    @order = Order.find_by(id: params[:order_id])
  end
end
