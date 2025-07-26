class OnsensController < ApplicationController
  before_action :set_onsen, only: %i[ show ]
  # GET /onsens or /onsens.json
  def index
    @onsens = Onsen.all
  end

  # GET /onsens/1 or /onsens/1.json
  def show
    @reviews = @onsen.reviews.order(created_at: :desc)
  end

  private
    def set_onsen
      @onsen = Onsen.find(params.expect(:id))
    end
end
