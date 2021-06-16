require "json"

class Config
    property url : String
    property fields : Array(String)
    property intervall : Int32
    property output : String
    property delimiter : String

    def initialize
        config = File.open("./src/config.json") do |file|
            JSON.parse(file)
        end
        @url = config["url"].as_s
        @intervall = config["intervall"].as_i
        @output = config["output"].as_s
        @delimiter = config["delimiter"].as_s
        @fields = [] of String
        config["fields"].as_a.each do |item|
            @fields.push(item.as_s)
        end
    end
end