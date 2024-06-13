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
      render json: { message: 'Cart item updated successfully.' }, status: :ok
    else
      render json: { error: @cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.destroy
      render json: {message: "Item removed from cart successfully"}, status: :ok
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
