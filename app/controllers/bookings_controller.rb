class BookingsController < ApplicationController
  def new
    @booking = Booking.new
  end

  def create
    @booking = Booking.new(booking_params)
    if @booking.save
      redirect_to root_path, notice: "You’re all set — booking received. I’ll reply soon."
    else
      flash.now[:alert] = "Please review the highlighted fields below."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:name, :guests, :preferred_dates, :location, :notes)
  end
end
