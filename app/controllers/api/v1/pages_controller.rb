class Api::V1::PagesController < ApplicationController
  before_action :authorize_admin, only: [:add_images, :destroy_image]
  def index
    pages = Page.all
    pages_with_details = pages.map do |page|
      {
        id: page.id,
        client_logos: page.client_logos.map { |logo| { id: logo.id, url: url_for(logo) } },
        images: page.images.map { |image| { id: image.id, url: url_for(image) } }
      }
    end
    render json: { pages: pages_with_details }, status: :ok
  end

  def add_images
    if params[:page][:images].present?
      page.images.attach(params[:page][:images])
      images_details = page.images.map do |image|
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

  def destroy_image
    image = ActiveStorage::Attachment.find(params[:image_id])
    if image.purge
      render json: {message: "Image deleted successfully"}, status: :ok
    else
      render json: {error: image.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def page_params
    params.require(:page).permit(images: [], client_logos: [])
  end

   def authorize_admin
    unless admin?
      render json: { error: "You are not authorized to perform this action" }, status: :unauthorized
    end
  end
end
