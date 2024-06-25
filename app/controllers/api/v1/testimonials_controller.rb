class Api::V1::TestimonialsController < ApplicationController
  before_action :set_testimonial, only: [:update, :destroy]
  def create
    testimonial = Testimonial.create(testimonial_params)
    if testimonial.save
      render json: {message: "Testimonial added successfully"}, status: :created
    else
      render json: {error: testimonial.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def index
    testimonials = Testimonial.all
    testimonials_with_urls = testimonials.map do |testimonial|
      {
        id: testimonial.id,
        content: testimonial.comment,
        user_name: testimonial.name,
        user_profile_url: testimonial.user_profile.attached? ? url_for(testimonial.user_profile) : nil
      }
    end
    render json: { testimonials: testimonials_with_urls }, status: :ok
  end

  def destroy
    if @testimonial.destroy
      render json: {message: "Testimonial deleted successfully"}, status: :ok
    else
      render json: {error: @testimonial.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def update
    if @testimonial.update(testimonial_params)
      render json: {message: "Testimonial updated successfully", testimonial: @testimonial}, status: :ok
    else
      render json: {error: @testimonial.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private
  def testimonial_params
    params.require(:testimonial).permit(:name, :comment, :user_profile)
  end

  def set_testimonial
    @testimonial = Testimonial.find(params[:id])
  end
end
