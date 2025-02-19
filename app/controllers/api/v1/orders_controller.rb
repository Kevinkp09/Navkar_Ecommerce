class Api::V1::OrdersController < ApplicationController
  before_action :set_cart, only: [:create]
  skip_before_action :doorkeeper_authorize!, only: [:payment_callback]

  def create
    @order = current_user.orders.build(order_params)
    @order.total_price = @cart.total_price
    @order.discounted_price = @cart.discounted_price.presence || @cart.total_price
    @order.address = params[:order][:address].presence || current_user.default_address
    if params[:order][:payment_method] == 'cod'
      @order.payment_status = 'pending'
      if @order.save
        create_order_items
        render json: {
          message: "COD Order created successfully. Awaiting admin confirmation.",
          order_id: @order.id
        }, status: :created
      else
        render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    else
      if @order.save
        amount = (@order.discounted_price) * 100
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
  end

  def payment_callback
    signature = request.headers['X-Razorpay-Signature']
    data = request.body.read
    secret = "45@4tB_wMSqRLEb"
    digest = OpenSSL::Digest.new('sha256')
    calculated_signature = OpenSSL::HMAC.hexdigest(digest, secret, data)

    if signature != calculated_signature
      render json: { message: 'Invalid signature' }, status: :bad_request
      return
    end
    payload = JSON.parse(data)
    event = payload['event']

    case event
    when 'order.paid'
      order_id = payload.dig('payload', 'payment', 'entity', 'order_id')
      payment_id = payload.dig('payload', 'payment', 'entity', 'id')
      email = payload.dig("payload", "payment", "entity", "email")
      @order = Order.find_by(razorpay_order_id: order_id)
      user = User.find_by(email: email)
      @cart = user.cart
      if @order.present?
        @order.update(payment_status: 'paid', status: "Order Submitted", razorpay_payment_id: payment_id)
        create_order_items
        render json: { message: "Payment successful and order is now submitted.", order: @order }, status: :ok
      else
        render json: { error: "Order not found" }, status: :not_found
      end
    else
      render json: { error: "Unhandled event type" }, status: :unprocessable_entity
    end
  end

  def index
    user = current_user
    @orders = user.role == "customer" ? user.orders.includes(order_items: :product, courier: nil) : Order.includes(:user, order_items: :product, courier: nil).all

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
        payment_status: order.payment_status,
        payment_method: order.payment_method,
        user: user.role == "customer" ? nil : order.user,
        courier: order.courier ? {
          id: order.courier.id,
          name: order.courier.name,
          website: order.courier.website
        } : "N/A",
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

    render json: { orders: orders_with_details, message: "Orders fetched successfully" }.compact, status: :ok
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
    if @order.update(courier: @courier, tracking_id: params[:tracking_id], status: params[:status], payment_status: params[:payment_status])
      render json: { message: "Courier and tracking ID assigned successfully.", order: @order}, status: :ok
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:status, :courier_id, :address, :uuid, :payment_method)
  end

  def find_order
    @order = Order.find_by(razorpay_order_id: params[:order_id])
    unless @order
      render json: { message: 'Order not found.' }, status: :not_found
    end
  end

  def set_cart
    @cart = current_user.cart
    @cart.reload
  end

  def create_order_items
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
  end

end
