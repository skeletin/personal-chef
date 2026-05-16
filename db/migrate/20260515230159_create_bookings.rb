class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.string :name, null: false
      t.string :guests
      t.string :preferred_dates
      t.string :location
      t.text :notes

      t.timestamps
    end
  end
end
