class Api::V1::OrdersController < ApplicationController
  before_action :set_cart, only: [:create]

  def create
    @order = current_user.orders.build(order_params)
    @order.total_price = @cart.total_price
    @order.discounted_price = @cart.discounted_price.presence || @cart.total_price
    @order.address = params[:order][:address].presence || current_user.default_address

    if @order.save
      amount = (@order.discounted_price || @order.total_price) * 100
      razorpay_order = Razorpay::Order.create(amount: amount.to_i, currency: 'INR')

      if razorpay_order.present? && razorpay_order.id.present?
        @order.update(razorpay_order_id: razorpay_order.id)

        render json: {
          message: "Order created successfully. Proceed to payment.",
          order_id: @order.id,
          razorpay_order_id: razorpay_order.id,
          amount: amount / 100.0
        }, status: :created
      else
        @order.destroy
        render json: { error: "Failed to create Razorpay order" }, status: :unprocessable_entity
      end
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def payment_callback
    order_id = params[:order_id]
    payment_id = params[:payment_id]

    razorpay_order = Razorpay::Order.fetch(order_id)

    if razorpay_order.status == 'paid'
      @order = Order.find_by(razorpay_order_id: order_id)

      if @order.present?
        @order.update(payment_status: 'paid', razorpay_payment_id: payment_id, status: :transit)

        @cart.cart_items.each do |cart_item|
          order_item = @order.order_items.build(
            product_id: cart_item.product_id,
            quantity: cart_item.quantity,
            price: cart_item.product.mrp,
            discounted_price: cart_item.product.discount_on_mrp
          )

          unless order_item.save
            render json: { errors: order_item.errors.full_messages }, status: :unprocessable_entity
            return
          end
        end
        @cart.update(total_price: nil, discounted_price: nil)
        @cart.cart_items.destroy_all

        render json: { message: "Payment successful and order is now in transit.", order: @order }, status: :ok
      else
        render json: { error: "Order not found" }, status: :not_found
      end
    else
      render json: { error: "Payment failed, please try again!" }, status: :unprocessable_entity
    end
  end

  def index
    user = current_user
    if user.role == "customer"
      @orders = user.orders.includes(order_items: :product, courier: nil)
      orders_with_details = @orders.map do |order|
        {
          id: order.id,
          status: order.status,
          total_price: order.total_price,
          discounted_price: order.discounted_price,
          address: order.address,
          tracking_id: order.tracking_id,
          created_at: order.created_at,
          uuid: order.uuid,
          courier: order.courier ? {
            id: order.courier.id,
            name: order.courier.name,
            website: order.courier.website
          } : nil,
          order_items: order.order_items.map do |item|
            {
              id: item.id,
              product_name: item.product.product_name,
              quantity: item.quantity,
              price: item.price,
              product_details: item.product.attributes
            }
          end
        }
      end
      render json: { orders: orders_with_details }, status: :ok
    else
      @orders = Order.includes(:user, order_items: :product, courier: nil).all
      orders_with_details = @orders.map do |order|
        {
          id: order.id,
          status: order.status,
          total_price: order.total_price,
          discounted_price: order.discounted_price,
          address: order.address,
          tracking_id: order.tracking_id,
          uuid: order.uuid,
          created_at: order.created_at,
          user: order.user.attributes,
          courier: order.courier ? {
            id: order.courier.id,
            name: order.courier.name,
            website: order.courier.website
          } : nil,
          order_items: order.order_items.map do |item|
            {
              id: item.id,
              product_name: item.product.product_name,
              quantity: item.quantity,
              price: item.price,
              product_details: item.product.attributes
            }
          end
        }
      end
      render json: { orders: orders_with_details, message: "Orders fetched successfully" }, status: :ok
    end
  end

  def update_status
    @order = Order.find(params[:order_id])
    new_status = params[:status]
    if @order.update(status: new_status)
      render json: { message: "Order status updated to #{new_status} successfully." }, status: :ok
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def assign_courier
    @order = Order.find(params[:order_id])
    @courier = Courier.find(params[:courier_id])

    if @order.update(courier: @courier, tracking_id: params[:tracking_id], status: params[:status])
      render json: { message: "Courier and tracking ID assigned successfully.", status: @order.status }, status: :ok
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:status, :courier_id, :address, :uuid)
  end

  def find_order
    @order = Order.find_by(razorpay_order_id: params[:order_id])
    unless @order
      render json: { message: 'Order not found.' }, status: :not_found
    end
  end
  
  def set_cart
    @cart = current_user.cart
  end
end
