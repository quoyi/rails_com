# frozen_string_literal: true

class Com::VideosController < Com::BaseController
  before_action :set_video, only: %i[show transfer]
  before_action do
    ActiveStorage::Current.host = request.base_url
  end

  def show
    expires_in ActiveStorage.service_urls_expire_in
  end

  def transfer
    attached = @attachment.transfer_faststart
    @video = attached.blob

    flash[:notice] = 'well done!'
    render 'show'
  end

  private

    def set_video
      @attachment = ActiveStorage::Attachment.find(params[:id])
      @video = @attachment.blob
    end
end
