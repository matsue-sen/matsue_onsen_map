class ReviewsController < ApplicationController
  before_action :set_onsen
  def new
    @review = @onsen.reviews.build
  end

  def create
    @review = @onsen.reviews.build(review_params)
    if @review.save
      redirect_to onsen_path(@onsen), notice: t("flash.review_created")
    else
      render "onsens/show", status: :unprocessable_entity
    end
  end

  private

    def set_onsen
      @onsen = Onsen.find(params[:onsen_id])
    end

    def review_params
      params.require(:review).permit(:rating, :comment)
    end
end
