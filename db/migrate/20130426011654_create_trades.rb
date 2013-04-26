class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.string :trade_type
      t.float :usd
      t.float :btc
      t.float :price

      t.timestamps
    end
  end
end
