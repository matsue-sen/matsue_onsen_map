class AddUrlToOnsens < ActiveRecord::Migration[8.0]
  def change
    add_column :onsens, :url, :string
  end
end
