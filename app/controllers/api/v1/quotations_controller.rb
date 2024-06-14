class Api::V1::QuotationsController < ApplicationController

  def create
    @quotation = Quotation.new(quotation_params.except(:quotation_items))
    total_price = 0
    discounted_total_price = 0

    if @quotation.save
      quotation_items_params.each do |item|
        product = Product.find(item[:product_id])
        price = product.mrp * item[:quantity]
        discount = item[:discount].to_f
        discounted_price = price - (price * discount / 100.0)

        total_price += price
        discounted_total_price += discounted_price

        @quotation.quotation_items.create!(
          product: product,
          quantity: item[:quantity],
          discount: discount,
          price: price,
          discounted_price: discounted_price
        )
      end
      @quotation.update(total_price: total_price, discounted_total_price: discounted_total_price)
      render json: { message: 'Quotation created successfully.', quotation_id: @quotation.id, total_price: total_price, discounted_total_price: discounted_total_price }, status: :created
    else
      render json: { errors: @quotation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    quotations = Quotation.includes(quotation_items: :product).all

    render json: quotations.map { |quotation|
      {
        id: quotation.id,
        name: quotation.name,
        email: quotation.email,
        mobile_number: quotation.mobile_number,
        address: quotation.address,
        total_price: quotation.total_price,
        discounted_total_price: quotation.discounted_total_price,
        created_at: quotation.created_at,
        updated_at: quotation.updated_at,
        quotation_items: quotation.quotation_items.map { |item|
          {
            id: item.id,
            product_id: item.product_id,
            quantity: item.quantity,
            discount: item.discount,
            price: item.price,
            discounted_price: item.discounted_price,
            product: item.product.attributes
          }
        }
      }
    }
  end

  def destroy
    quotation = Quotation.find(params[:id])
    if quotation.destroy
      render json: {message: "Quotation deleted successfully"}, status: :ok
    else
      render json: {error: quotation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    @quotation = Quotation.find(params[:id])
    total_price = 0
    discounted_total_price = 0
    if @quotation.update(quotation_params.except(:quotation_items))
      current_item_ids = @quotation.quotation_items.pluck(:id)
      received_item_ids = quotation_items_params.map { |item| item[:id] }.compact

      items_to_remove = current_item_ids - received_item_ids
      @quotation.quotation_items.where(id: items_to_remove).destroy_all

      quotation_items_params.each do |item|
        if item[:id].present?
          existing_item = @quotation.quotation_items.find(item[:id])
          product = existing_item.product
          price = product.mrp * item[:quantity]
          discount = item[:discount].to_f
          discounted_price = price - (price * discount / 100.0)

          total_price += price
          discounted_total_price += discounted_price

          existing_item.update!(
            quantity: item[:quantity],
            discount: discount,
            price: price,
            discounted_price: discounted_price
          )
        else
          product = Product.find(item[:product_id])
          price = product.mrp * item[:quantity]
          discount = item[:discount].to_f
          discounted_price = price - (price * discount / 100.0)

          total_price += price
          discounted_total_price += discounted_price

          @quotation.quotation_items.create!(
            product: product,
            quantity: item[:quantity],
            discount: discount,
            price: price,
            discounted_price: discounted_price
          )
        end
      end

      @quotation.update(total_price: total_price, discounted_total_price: discounted_total_price)

      render json: {
        message: 'Quotation updated successfully.',
        quotation_id: @quotation.id,
        total_price: total_price,
        discounted_total_price: discounted_total_price
      }, status: :ok
    else
      render json: { errors: @quotation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def quotation_params
    params.require(:quotation).permit(:name, :email, :mobile_number, :address,  quotation_items: [:product_id, :quantity, :discount])
  end

  def quotation_items_params
    params[:quotation][:quotation_items]
  end
end
