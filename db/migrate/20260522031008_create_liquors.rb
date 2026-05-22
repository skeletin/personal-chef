class CreateLiquors < ActiveRecord::Migration[8.1]
  def change
    create_table :liquors do |t|
      t.string :name, null: false
      t.integer :quantity, null: false, default: 0
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :category
      t.text :notes

      t.timestamps
    end

    add_index :liquors, :name, unique: true
    add_check_constraint :liquors, "quantity >= 0", name: "liquors_quantity_non_negative"
    add_check_constraint :liquors, "price >= 0", name: "liquors_price_non_negative"
  end
end
