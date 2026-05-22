class DropBookings < ActiveRecord::Migration[8.1]
  def up
    drop_table :bookings, if_exists: true
  end

  def down
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
