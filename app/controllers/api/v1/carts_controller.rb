class Api::V1::CartsController < ApplicationController
  before_action :set_cart

  def index
    cart_items = @cart.cart_items.includes(:product)
    cart_items_with_details = cart_items.map do |item|
      discounted_price = item.product.mrp - (item.product.mrp * (item.product.discount || 0) / 100.0)
      {
        id: item.id,
        quantity: item.quantity,
        product: item.product.attributes.merge(discounted_price: discounted_price),
        product_url: url_for(item.product.main_image)
      }
    end

    total_price = cart_items.sum { |item| item.product.mrp - (item.product.mrp * (item.product.discount || 0) / 100.0) * item.quantity }

    render json: {
      cart_items: cart_items_with_details,
      total_price: total_price
    }
  end

  private

  def set_cart
    @cart = current_user.cart
  end
end

