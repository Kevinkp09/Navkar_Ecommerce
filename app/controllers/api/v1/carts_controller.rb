class Api::V1::CartsController < ApplicationController
  before_action :set_cart

  def index
    cart_items = @cart.cart_items.includes(:product)
    total_discounted_price = 0
    total_mrp = 0
    cart_items_with_details = cart_items.map do |item|
      discounted_price = item.product.discount_on_mrp * item.quantity
      total_price = item.product.mrp * item.quantity
      total_discounted_price += discounted_price
      total_mrp += total_price
      {
        id: item.id,
        quantity: item.quantity,
        product: item.product.attributes.merge(discounted_price: discounted_price),
        product_url: url_for(item.product.main_image)
      }
    end

    if cart_items.empty?
      total_discounted_price = 0
      total_mrp = 0
      @cart.update(total_price: total_mrp, discounted_price: total_discounted_price, is_coupon_applied: false)
    elsif @cart.is_coupon_applied
      total_discounted_price = @cart.discounted_price
    else
      @cart.update(total_price: total_mrp, discounted_price: total_discounted_price)
    end

    render json: {
      cart_items: cart_items_with_details,
      total_price: total_mrp,
      discounted_price: total_discounted_price,
      is_coupon_applied: @cart.is_coupon_applied,
      user: current_user
    }, status: :ok
  end

  def apply_coupon
    coupon = Coupon.find_by(code: params[:coupon_code])
    if coupon
      total_price = 0
      @cart.cart_items.each do |cart_item|
        total_price += cart_item.product.discount_on_mrp * cart_item.quantity
      end
      if total_price >= coupon.amount
        discount_amount = total_price * (coupon.discount / 100.0)
        discounted_price = total_price - discount_amount
        @cart.update(total_price: total_price, discounted_price: discounted_price, is_coupon_applied: true)
        render json: { message: 'Coupon applied successfully.', total_price: total_price, discounted_price: discounted_price, discount_amount: discount_amount, cart_id: @cart.id }, status: :ok
      else
        render json: { errors: 'Total price does not meet the minimum amount for the coupon' }, status: :unprocessable_entity
      end
    else
      render json: { errors: 'Invalid coupon code' }, status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = current_user.cart
  end
end
