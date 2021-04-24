require "json"
require "http/client"
require "tablo"
require "./subdomain-list"

class Checker
    property list : Array(String | Nil) | Array(String)
    property domain : String
    property results : Array(String)
    property workers : Int32

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
        @workers = config["workers"].as_i
    end

    def run
        sub_stream = Channel({String | Nil, Int32}).new
        result_stream = Channel(String).new
        count = 0
        spawn do
            @list.map_with_index{|subdomain, index| sub_stream.send({subdomain, index})}
        end
        @workers.times {
            spawn do
                loop do
                    subdomain, index = sub_stream.receive
                    count = index + 1
                    url = "#{subdomain}.#{@domain}"
                    puts "Checking #{url}... #{count}/#{@list.size}"
                    begin
                        HTTP::Client.get "http://#{url}" do |result|
                            if result.status_code == 200 || result.status_code == 301
                                result_stream.send url
                            end
                        end
                    rescue exception
                    end
                end
            end
        }
        loop do
            url = result_stream.receive
            @results.push(url)
            if count == @list.size
                break
            end
        end
    end

    def print
        data = @results.map{|item| [item.split(".")[0], item]}
        data.push ["Found:", "#{@results.size}"]
        table = Tablo::Table.new(data) do |t|
            t.add_column("Subdomains", width: 10) {|n| n[0]}
            t.add_column("Urls", width: 20) {|n| n[1]}
        end
        puts table
    end
end

checker = Checker.new
checker.run
checker.print