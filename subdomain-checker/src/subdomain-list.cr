require "json"
require "http/client"

class Subdomains
    property filename : String
    property subdomains : Array(String)

    def initialize
        config = File.open("./src/config.json") do |file|
            JSON.parse(file)
        end
        chosen = config["subdomain-lists"].as_a[config["list-num"].as_i]
        case chosen
        when 100, 500, 1000, 10000
            @filename = "subdomains-#{chosen}.txt"
        else
            @filename = "subdomains.txt"
        end
        @subdomains = Array(String).new
    end

    def getList
        url = "https://raw.githubusercontent.com/rbsec/dnscan/master/#{@filename}"
        begin
            HTTP::Client.get url do |result|
                result.body_io.each_line do |line|
                    @subdomains.push line.delete("\n")
                end
                @subdomains
            end
        rescue exception : Socket::Addrinfo::Error
            ["#{exception.error_code}"]
        rescue exception
            [exception.message]
        end
    end
end
