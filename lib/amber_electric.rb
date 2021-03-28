require "net/http"
require "json"
require "tzinfo"
require "bigdecimal"
require "time"

module AmberElectric
  
  class Client
    def self.prices_for(postcode: )
      self.new.prices_for(postcode: postcode)
    end

    # curl -X POST "https://api.amberelectric.com.au/prices/listprices"   -H 'Content-Type: application/json'   -d '{ "postcode": "3058" }'
    def prices_for(postcode: )
      http = Net::HTTP.new("api.amberelectric.com.au", 443)
      http.use_ssl = true

      request = Net::HTTP::Post.new("/prices/listprices")
      request["Content-Type"] = "application/json"
      request.body = {postcode: postcode.to_s}.to_json

      response = http.request(request)

      if response.code.to_i == 200
        data = JSON.parse(response.body)
        
        Prices.new(
          market_period_end: current_period_end,
          static_import_cents_per_kwh: per_kwh(data, "E1"),
          controlled_load_cents_per_kwh: per_kwh(data, "E2"),
          export_cents_per_kwh: per_kwh(data, "B1")
        )
      else
        raise "Error fetching prices: #{response.inspect}"
      end
    end

    private

    def current_period_end
      tz = TZInfo::Timezone.get('Australia/Brisbane')
      market_time = tz.now
      if market_time.min >= 0 and market_time.min <= 30
        market_period_end = tz.local_time(market_time.year, market_time.month, market_time.day, market_time.hour, 30)
      else
        market_period_end = tz.local_time(market_time.year, market_time.month, market_time.day, market_time.hour+1)
      end
    end

    def per_kwh(data, type)
      total_fixed_kwh_price = BigDecimal(data.fetch("data", {}).fetch("staticPrices", {}).fetch(type, {}).fetch("totalfixedKWHPrice", "0"))
      loss_factor = BigDecimal(data.fetch("data", {}).fetch("staticPrices", {}).fetch("E1", {}).fetch("lossFactor", "0"))
      market_period_end_iso8601 = current_period_end.strftime("%Y-%m-%dT%H:%M:%S")
      
      current_actual = data.fetch("data", {}).fetch("variablePricesAndRenewables", []).select { |row|
        row["periodType"] == "ACTUAL"
      }.select { |row|
        row["period"] == market_period_end_iso8601 
      }.first

      if current_actual
        (total_fixed_kwh_price + (loss_factor * BigDecimal(current_actual.fetch("wholesaleKWHPrice", "0")))).round(3)
      end
    end
  end
  class Prices

    attr_reader :market_period_end
    attr_reader :static_import_cents_per_kwh, :controlled_load_cents_per_kwh, :export_cents_per_kwh

    def initialize(market_period_end:, static_import_cents_per_kwh: , controlled_load_cents_per_kwh: , export_cents_per_kwh: )
      @market_period_end = market_period_end
      @static_import_cents_per_kwh = static_import_cents_per_kwh
      @controlled_load_cents_per_kwh = controlled_load_cents_per_kwh
      @export_cents_per_kwh = export_cents_per_kwh
    end

    def self.for(postcode: )
      AmberElectric::Client.prices_for(postcode: postcode)
    end

  end
end
