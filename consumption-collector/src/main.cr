require "./config"
require "./database"
require "./fetcher"
require "./analyzer"

config = Config.new
db = Database.new config
puts "Starting..."
loop do
    begin
        fetcher = Fetcher.new config
        res = fetcher.fetch
        puts res
        time = Time.local Time::Location.load("Europe/Berlin")
        db.appendMeasurement(time.to_s("%Y-%m-%d"), time.to_s("%H:%M:%S"), res)
        sleep config.intervall.second
    rescue exception
        puts exception
        postAnalysis db, config
        exit
    end
    Signal::INT.trap do
        postAnalysis db, config
        exit
    end
end

def postAnalysis(db, config)
    puts "\nAnalyzing..."
    analyzer = Analyzer.new config
    config.fields.each do |field|
        list = db.getMeasurements field
        analyzer.exportFile list, field
    end
    puts "Finished"
end