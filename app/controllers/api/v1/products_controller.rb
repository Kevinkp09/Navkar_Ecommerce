class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: [:update, :destroy, :show]

  def index
    products = Product.all
    render json: products, status: :ok
  end

  def show
    product = @product.attributes.merge()
    render json: { product: product, message: 'product has been fetched successfully.' }, status: :ok
  end

  def create
    product = Product.new(product_params)
    if product.save
      render json: {product: ,message: "product successfully created"}, status: :created
    else
      render json: {error: product.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: { product: @product, message: 'product has been updated successfully.' }, status: :ok
    else
      render json: { product: @product, message: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      render json: { message: 'product has been deleted successfully.' }, status: :ok
    else
      render json: { message: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
    render json: { message: 'Record not found' }, status: :not_found unless @product
  end

  def product_params
    params.require(:product).permit(:category, :product_name, :brand_name, :product_model_name, :connecting_technology, :mobile_application, :product_model_no, :asin_no, :country, :description, :special_features, :features, :warranty, :mrp, :gst, :height, :width, :depth, :weight, :material, :discount, :price, :delivery_time, :coupon_name, :coupon_discount, :info, :main_image, other_images: [])
  end
end
