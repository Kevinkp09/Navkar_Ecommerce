class Api::V1::OrdersController < ApplicationController
  before_action :set_cart, only: [:create]

  def create
    total_price = 0
    @order = current_user.orders.build(order_params)

    @cart.cart_items.each do |cart_item|
      discounted_price = cart_item.product.mrp - (cart_item.product.mrp * (cart_item.product.discount || 0) / 100.0)
      total_price += discounted_price * cart_item.quantity
    end

    @order.total_price = total_price

    if @order.save
      @cart.cart_items.each do |cart_item|
        discounted_price = cart_item.product.mrp - (cart_item.product.mrp * (cart_item.product.discount || 0) / 100.0)
        order_item = @order.order_items.build(
          product_id: cart_item.product_id,
          quantity: cart_item.quantity,
          price: cart_item.product.mrp,
          discounted_price: discounted_price
        )

        unless order_item.save
          render json: { errors: order_item.errors.full_messages }, status: :unprocessable_entity
          return
        end
      end
      @cart.cart_items.destroy_all
      render json: { message: 'Order placed successfully.', order_id: @order.id, total_price: total_price }, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def index
    user = current_user
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
  end

  private

  def order_params
    params.require(:order).permit(:status, :courier_id)
  end

  def set_cart
    @cart = current_user.cart
  end
end
