class AddPriceToOnsens < ActiveRecord::Migration[8.0]
  def change
    add_column :onsens, :price, :integer
  end
end
