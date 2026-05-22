class Admin::LiquorsController < Admin::BaseController
  before_action :set_liquor, only: %i[ edit update destroy ]

  def index
    @liquors = Liquor.with_attached_photo.order(
      Arel.sql("NULLIF(TRIM(category), '') NULLS LAST"),
      Arel.sql("LOWER(liquors.name)")
    )
  end

  def new
    @liquor = Liquor.new
  end

  def create
    @liquor = Liquor.new(liquor_params)
    if @liquor.save
      redirect_to admin_liquors_path, notice: "Added #{@liquor.name} to inventory."
    else
      flash.now[:alert] = "Please fix the highlighted fields."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    purge_photo_if_requested

    if @liquor.update(liquor_params)
      redirect_to admin_liquors_path, notice: "Updated #{@liquor.name}."
    else
      flash.now[:alert] = "Please fix the highlighted fields."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    name = @liquor.name
    @liquor.destroy!
    redirect_to admin_liquors_path, notice: "Removed #{name} from inventory.", status: :see_other
  end

  private

    def set_liquor
      @liquor = Liquor.find(params[:id])
    end

    def liquor_params
      params.require(:liquor).permit(
        :name, :quantity, :price, :category, :notes, :photo,
        :typical_store_price, :comparison_note, :comparison_url
      )
    end

    def purge_photo_if_requested
      purge = ActiveModel::Type::Boolean.new.cast(params.dig(:liquor, :remove_photo))
      incoming = params.dig(:liquor, :photo)
      @liquor.photo.purge if purge && !incoming.present?
    end
end
