class LiquorsController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    @liquors = Liquor.with_attached_photo.order(
      Arel.sql("NULLIF(TRIM(category), '') NULLS LAST"),
      Arel.sql("LOWER(liquors.name)")
    )
  end
end
