require "./config"
require "./database"
require "./fetcher"
require "./analyzer"

config = Config.new
db = Database.new config
loop do
    begin
        fetcher = Fetcher.new config
        res = fetcher.fetch
        p res
        time = Time.local Time::Location.load("Europe/Berlin")
        db.appendMeasurement(time.to_s("%Y-%m-%d"), time.to_s("%H:%M:%S"), res)
        sleep config.intervall.second
    rescue exception
        postAnalysis db, config
        exit
    end
    Signal::INT.trap do
        postAnalysis db, config
        exit
    end
end

def postAnalysis(db, config)
    key = "power"
    list = db.getMeasurements key
    analyzer = Analyzer.new config
    analyzer.exportFile list
end