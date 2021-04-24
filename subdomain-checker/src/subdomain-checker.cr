require "json"
require "http/client"
require "tablo"
require "./subdomain-list"

class Checker
    property list : Array(String | Nil) | Array(String)
    property domain : String
    property results : Array(String)

    def initialize
        config = File.open("./src/config.json") do |file|
        JSON.parse(file)
        end
        puts "Configuration: #{config}"

        subdomains = Subdomains.new
        fetchedSubdomains = subdomains.getList
        if fetchedSubdomains
            @list = fetchedSubdomains
        else
            @list = Array(String).new
            puts "Error fetching Subdomain file: #{fetchedSubdomains}"
        end
        @domain = config["domain"].as_s
        @results = Array(String).new
    end

    def run
        @list.map_with_index do |subdomain, index|
            url = "#{subdomain}.#{@domain}"
            begin
                HTTP::Client.get "http://#{url}" do |result|
                    if result.status_code == 200 || result.status_code == 301
                        @results.push url
                        puts "...was successful!"
                    end
                end
            rescue exception
            end
            puts "Checking #{url}... #{index}/#{@list.size}"
        end
    end

    def print
        data = @results.map{|item| [item[0]]}
        table = Tablo::Table.new(data) do |t|
            t.add_column("Subdomains") {|n| n[0]}
        end
        puts table
    end
end

checker = Checker.new
checker.run
checker.print