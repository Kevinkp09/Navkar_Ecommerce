class Api::V1::OrdersController < ApplicationController
  before_action :set_cart, only: [:create]

  def create
    @order = current_user.orders.build(order_params)
    @order.total_price = @cart.total_price
    @order.discounted_price = @cart.discounted_price.presence || @cart.total_price
    @order.address = params[:order][:address].presence || current_user.default_address

    if @order.save
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
      render json: { message: 'Order placed successfully.', order_id: @order.id, total_price: @order.total_price, discounted_price: @order.discounted_price }, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def index
    user = current_user
    if user.role == "customer"
      @orders = user.orders.includes(order_items: :product)
      orders_with_details = @orders.map do |order|
        {
          id: order.id,
          status: order.status,
          total_price: order.total_price,
          tracking_id: order.tracking_id,
          created_at: order.created_at,
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
      @orders = Order.includes(:user, order_items: :product).all
      orders_with_details = @orders.map do |order|
        {
          id: order.id,
          status: order.status,
          total_price: order.total_price,
          tracking_id: order.tracking_id,
          created_at: order.created_at,
          user: order.user.attributes,
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

  private

  def order_params
    params.require(:order).permit(:status, :courier_id, :address) 
  end

  def set_cart
    @cart = current_user.cart
  end
end
