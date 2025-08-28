class AddSalesAndHolidayToOnsens < ActiveRecord::Migration[6.1]
  def change
    add_column :onsens, :sales_s, :string
    add_column :onsens, :sales_f, :string
    add_column :onsens, :holiday, :string
  end
end
