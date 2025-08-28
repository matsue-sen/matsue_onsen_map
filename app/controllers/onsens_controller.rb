class OnsensController < ApplicationController
  before_action :set_onsen, only: %i[ show ]
  # GET /onsens or /onsens.json
  def index
    # Strong Parametersで安全なパラメータのみ許可（boundsを追加）
    @search_params = params.permit(:q, :tags, :bounds)

    # モデルの検索メソッドを呼び出し、新しい順でソート
    @onsens = Onsen.search(@search_params).order(created_at: :desc)

    # 地図の表示範囲で絞り込み
    if @search_params[:bounds].present?
      bounds = @search_params[:bounds].split(",")
      @onsens = @onsens.within_bounds(bounds)
    end

    # セッションリセット
    reset_admin_session
  end





  # GET /onsens/1 or /onsens/1.json
  def show
    @reviews = @onsen.reviews.order(created_at: :desc)
  end

  private
    def set_onsen
      @onsen = Onsen.find(params[:id])
    end

    def onsen_params
      params.require(:onsen).permit(:name, :sales_s, :sales_f, :holiday, :other_columns)
    end
end
