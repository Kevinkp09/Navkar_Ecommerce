class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: [:update, :show, :destroy]

  def index
    categories = Category.all
    render json: {message: "Categories fetched successfully", categories: categories}, status: :ok
  end
  
  def create
    category = Category.new(category_params)
    if category.save
      render json: {message: "Categoty created successfully", category: category}, status: :ok
    else
      render json: {error: category.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    category = @category.attributes.merge()
    render json: { category: category, message: 'category has been fetched successfully.' }, status: :ok
  end

  def update
    if @category.update(category_params)
      render json: { category: @category, message: 'category has been updated successfully.' }, status: :ok
    else
      render json: { category: @category, message: @category.errors.full_messages }, status: :unprocessable_entity
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

  def category_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
