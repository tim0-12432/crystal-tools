require "http/client"
require "tablo"
require "json"

config = File.open("./src/config.json") do |file|
  JSON.parse(file)
end
puts "Configuration: #{config}"

url_stream = Channel(String).new
result_stream = Channel({String, Int32 | String | Nil, Bool}).new

spawn do
    config["urls"].as_a.each{|url| url_stream.send url.as_s}
end

get_status = -> (url : String) {
    begin
        HTTP::Client.get url do |result|
            {url, result.status_code, result.success?}
        end
    rescue exception : Socket::Addrinfo::Error
        {url, exception.error_code, false}
    rescue exception
        {url, exception.message, false}
    end
}

config["workers"].as_i.times {
    spawn do
        loop do
            url = url_stream.receive
            result = get_status.call(url)
            result_stream.send result
        end
    end
}


stats = {"successes" => 0, "failures" => 0}
results = Array({String, Int32 | String | Nil}).new
loop do
    puts "URL #{results.size + 1} out of #{config["urls"].as_a.size}"
    url, status, success = result_stream.receive
    results.push({url, status})
    if success
        stats["successes"] += 1
    else
        stats["failures"] += 1
    end

    if results.size == config["urls"].as_a.size
        break
    end
end

data1 = results.map{|item| [item[0], typeof(item[1].to_s) == String ? item[1] : 0]}
table1 = Tablo::Table.new(data1) do |t|
    t.add_column("Url") {|n| n[0]}
    t.add_column("Status") {|n| n[1]}
end
puts table1

data2 = [[config["urls"].as_a.size, stats["successes"], stats["failures"]]]
table2 = Tablo::Table.new(data2) do |t|
    t.add_column("Total") {|n| n[0]}
    t.add_column("Successess") {|n| n[1]}
    t.add_column("Failures") {|n| n[2]}
end
puts table2