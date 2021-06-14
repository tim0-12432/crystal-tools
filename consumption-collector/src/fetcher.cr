require "crest"
require "json"
require "http/client"

class Fetcher
    property url : String
    property fields : Array(String)
    property result : Array(Int32 | Float64)

    def initialize(config)
        @url = config.url
        @fields = config.fields
        @result = Array(Int32 | Float64).new
    end

    def fetch
        response = Hash(String, Int32 | Float64 | String).new
        HTTP::Client.get @url do |result|
            if result.status_code == 200 || result.status_code == 301
                body = result.body_io.gets
                if !body.nil?
                    response = JSON.parse(body).as_h["StatusSNS"].as_h["ENERGY"].as_h
                end
            end
        end
        @fields.each do |field|
            p field.capitalize
            value = response[field.capitalize]
            if value.is_a?(JSON::Any)
                value = value.as_i
            end
            if value.is_a?(Float64) || value.is_a?(Int32)
                @result.push(value)
            end
        end
        @result
    end
end