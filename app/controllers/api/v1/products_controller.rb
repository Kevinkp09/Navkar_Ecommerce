class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: [:update, :destroy, :show]

  def index
    products = Product.all
    products_data = products.map do |product|
      product.attributes.merge(
        category: product.category.name,
        main_image_url: product.main_image.attached? ? url_for(product.main_image) : nil,
        other_images_urls: product.other_images.attached? ? product.other_images.map { |image| url_for(image) } : [],
        brochure_url: product.brochure.attached? ? url_for(product.brochure) : nil
      )
    end
    render json: { products: products_data }, status: :ok
  end

  def show
    category = @product.category
    category_name = category.present? ? category.name : nil
    main_image_url = url_for(@product.main_image) if @product.main_image.attached?
    other_images_urls = @product.other_images.map { |img| url_for(img) } if @product.other_images.attached?
    brochure_url = url_for(@product.brochure) if @product.brochure.attached?
    render json: {
      product_details: @product.attributes.merge,
      category_name: category_name,
      main_image: main_image_url,
      other_images: other_images_urls,
      brochure: brochure_url
    }
  end

  def create
    product = Product.new(product_params)
    if product.save
      render json: { product: product, category_name: product.category.name, message: "Product successfully created" }, status: :created
    else
      render json: { error: product.errors.full_messages }, status: :unprocessable_entity
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

  def add_images
    @product = Product.find(params[:product_id])
    if params[:other_images].present?
      @product.images.attach(params[:other_images])
      images_details = @product.images.map do |image|
        {
          id: image.id,
          filename: image.filename.to_s,
        }
      end
      render json: { message: "Image added successfully", images: images_details }, status: :ok
    else
      render json: { error: 'No images provided' }, status: :unprocessable_entity
    end
  end

  def delete_image
    image = ActiveStorage::Attachment.find(params[:id])
    if image.purge
      render json: {message: "Image deleted successfully"}, status: :ok
    else
      render json: {error: image.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def upload_product_images(product, images_params)
    images_to_attach = []
    images_params = [images_params] unless images_params.is_a?(Array)
    images_params.each do |image_data|
      begin
        decoded_data = URI.open(image_data)
      rescue OpenURI::HTTPError => e
        puts "Error downloading image: #{e.message}"
        next
      end
      images_to_attach << {
        io: decoded_data,
        content_type: "image/jpg",
        filename: "#{rand(0..100)}.jpg"
      }
    end
    product.other_images.attach(images_to_attach) if images_to_attach.size.positive?
  end

  def set_product
    @product = Product.find(params[:id])
    render json: { message: 'Product not found' }, status: :not_found unless @product
  end

  def product_params
    params.require(:product).permit(
      :category_id, :product_name, :brand_name, :product_model_name,
      :connecting_technology, :mobile_application, :product_model_no, :asin_no,
      :country, :description, :warranty, :mrp, :gst, :height, :width, :depth,
      :weight, :material, :discount, :price, :delivery_time, :coupon_name,
      :coupon_discount, :info, :main_image, :brochure, other_images: [], features: [], special_features: []
    )
  end
end
