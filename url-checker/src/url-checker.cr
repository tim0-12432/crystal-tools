require "http/client"

WORKERS = 3
URLS = [
    "http://google.com",
    "https://www.w3schools.com",
    "https://amazon.co.uk",
    "https://github.com/non-existing-project",
    "https://crystal-lang.org",
    "http://123.non-existent-page.de"
]

url_stream = Channel(String).new
result_stream = Channel({String, Int32 | Exception, Bool}).new

spawn do
    URLS.each{|url| url_stream.send url}
end

get_status = -> (url : String) {
    begin
        HTTP::Client.get url do |result|
            {url, result.status_code, result.success?}
        end
    rescue exception : Socket::Addrinfo::Error
        {url, exception, false}
    end
}

WORKERS.times {
    spawn do
        loop do
            url = url_stream.receive
            result = get_status.call(url)
            result_stream.send result
        end
    end
}

stats = {"successes" => 0, "failures" => 0}
results = Array({String, Int32 | Exception}).new
loop do
    url, status, success = result_stream.receive
    results.push({url, status})
    if success
        stats["successes"] += 1
    else
        stats["failures"] += 1
    end
end
puts results

#p URLS.map{|url| get_status.call(url)}