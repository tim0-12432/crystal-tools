require "json"
require "ishi"

class Config
    property url : String
    property output : String
    property delimiter : String
    property fields : Array(String)

    def initialize
        config = File.open("./src/config.json") do |file|
            JSON.parse(file)
        end
        @url = config["url"].as_s
        @output = config["output"].as_s
        @delimiter = config["delimiter"].as_s
        @fields = [] of String
        config["fields"].as_a.each do |item|
            @fields.push(item.as_s)
        end
    end
end