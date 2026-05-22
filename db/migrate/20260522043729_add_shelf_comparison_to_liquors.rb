class AddShelfComparisonToLiquors < ActiveRecord::Migration[8.1]
  def change
    add_column :liquors, :typical_store_price, :decimal, precision: 10, scale: 2
    add_column :liquors, :comparison_note, :text
    add_column :liquors, :comparison_url, :text

    add_check_constraint :liquors, "typical_store_price IS NULL OR typical_store_price >= 0",
      name: "liquors_typical_store_price_non_negative"
  end
end
