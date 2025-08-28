class Admin::OnsensController < Admin::AdminController
  before_action :set_onsen, only: %i[ show edit update destroy ]

  # GET /onsens
  def index
    session[:admin] = nil

    @onsens = Onsen.all
  end

  # GET /onsens/1
  def show
  end

  # GET /onsens/new
  def new
    @onsen = Onsen.new
  end

  # GET /onsens/1/edit
  def edit
  end

  # POST /onsens
  def create
    @onsen = Onsen.new(onsen_params)

    respond_to do |format|
      if @onsen.save
        format.html { redirect_to admin_onsen_path(@onsen), notice: "Onsen was successfully created." }
        format.json { render :show, status: :created, location: @onsen }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @onsen.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /onsens/1
  def update
    respond_to do |format|
      if @onsen.update(onsen_params.except(:remove_image_ids))
        if onsen_params[:remove_image_ids].present?
          onsen_params[:remove_image_ids].each do |image_id|
            image = @onsen.images.find_by(id: image_id)
            image.purge if image
          end
        end

        format.html { redirect_to admin_onsen_path(@onsen), notice: "Onsen was successfully updated." }
        format.json { render :show, status: :ok, location: @onsen }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @onsen.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /onsens/1
  def destroy
    @onsen.destroy!

    respond_to do |format|
      format.html { redirect_to admin_onsens_path, status: :see_other, notice: "Onsen was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_onsen
    @onsen = Onsen.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def onsen_params
    params.require(:onsen).permit(:name, :geo_lat, :geo_lng, :description, :tags, :url, :sales_s, :sales_f, :holiday, :address, :price, images: [], remove_image_ids: [])
  end
end
