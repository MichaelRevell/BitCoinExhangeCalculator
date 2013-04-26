require 'json'
require 'net/http'

class Trade < ActiveRecord::Base
  attr_accessible :btc, :trade_type, :usd, :price
  before_create :validate_trade
  def validate_trade
    # Get Data from MtGox
    r = Net::HTTP.get_response("data.mtgox.com", "/api/1/BTCUSD/depth/fetch")
    asks = JSON.parse(r.body)["return"]["asks"]
    bids = JSON.parse(r.body)["return"]["bids"]
    self.price = nil

    # Is this a buy or a sell?
    if self.trade_type == "buy"
      trades = asks
    else
      # This is a sell not a buy
      trades = bids
    end

    # Are we talking in terms of BTC or dollars?
    if self.usd.nil? # Then we use BTC
      while self.price.nil? and trade = trades.shift
        if self.btc < trade["amount"]
          # We can use this price because there is enough depth
          self.price = trade["price"]
        end
      end
      self.usd = self.btc * price
    else
      # Use USD since we have it
      while self.price.nil? and trade = trades.shift
        if self.usd < trade["amount"]
          # We can use this price because there is enough depth
          self.price = trade["price"]
        end
      end
      self.btc = self.usd /  price
    end
    
    # Account for fee
    if self.trade_type == "buy"
      self.btc = self.btc * 0.99
    else
      self.usd = self.usd * 0.99
    end
  
  end
end
