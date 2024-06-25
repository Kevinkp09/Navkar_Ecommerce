class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: [:update, :show, :destroy]
  before_action :authorize_admin
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
    if @category.destroy
      render json: { message: 'category has been deleted successfully.' }, status: :ok
    else
      render json: { message: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def authorize_admin
    unless admin?
      render json: { error: "You are not authorized to perform this action" }, status: :unauthorized
    end
  end
end
