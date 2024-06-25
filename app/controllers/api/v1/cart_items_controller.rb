class Api::V1::CartItemsController < ApplicationController
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]

  def create
    product = Product.find(cart_item_params[:product_id])
    @cart_item = @cart.cart_items.find_or_initialize_by(product: product)

    if @cart_item.new_record?
      @cart_item.quantity = cart_item_params[:quantity] || 1
    else
      @cart_item.quantity += cart_item_params[:quantity] || 1
    end
    if @cart_item.save
      render json:  {message: 'Item added to cart successfully.', id: @cart_item.id}, status: :ok
    else
      render json: {error: @cart_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.update(cart_item_params)
      total_discounted_price = @cart.cart_items.includes(:product).sum { |item| item.product.discount_on_mrp * item.quantity }
      total_price = @cart.cart_items.includes(:product).sum { |item| item.product.mrp * item.quantity }

      if @cart.is_coupon_applied
        discounted_price = total_discounted_price
      else
        discounted_price = total_discounted_price
      end
      @cart.update(total_price: total_price, discounted_price: discounted_price)
      render json: { message: 'Cart item updated successfully.', total_price: total_price, discounted_price: discounted_price }, status: :ok
    else
      render json: { error: @cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.destroy
      if @cart.cart_items.empty?
        @cart.update(total_price: 0, discounted_price: 0, is_coupon_applied: false)
      else
        total_discounted_price = @cart.cart_items.includes(:product).sum { |item| item.product.discount_on_mrp * item.quantity }
        total_price = @cart.cart_items.includes(:product).sum { |item| item.product.mrp * item.quantity }
        if @cart.is_coupon_applied
          total_discounted_price = @cart.discounted_price
        else
          @cart.update(total_price: total_price, discounted_price: total_discounted_price)
        end
        @cart.update(total_price: total_price, discounted_price: total_discounted_price)
      end
      render json: {message: "Item removed from cart successfully", total_price: total_price, discounted_price: total_discounted_price}, status: :ok
    else
      render json: {error: @cart_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def cart_item_params
    params.require(:cart_item).permit(:product_id, :quantity)
  end

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end
