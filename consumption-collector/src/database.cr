require "sqlite3"

class Database
    property databasePath : String
    property dataFields : Array(String)

    def initialize(config)
        @databasePath = "sqlite3://./data.db"
        cleanDb

        @dataFields = config.fields
        fields = ""
        @dataFields.each do |field|
            fields += ", #{field} REAL"
        end
        DB.open @databasePath do |db|
            db.exec "CREATE TABLE IF NOT EXISTS measurements (date DATE, time TIME#{fields})"
        end
    end

    def appendMeasurement(date, time, data)
        columns = "date, time"
        fields = "\"#{date}\", \"#{time}\""
        @dataFields.each_index do |index|
            fields += ", #{data[index]}"
        end
        @dataFields.each do |field|
            columns += ", #{field}"
        end
        DB.open @databasePath do |db|
            db.exec "INSERT INTO measurements (#{columns}) VALUES (#{fields})"
        end
    end

    def getMeasurements(key)
        measurements = Array(NamedTuple(date: String, time: String, value: Float64 | Int64)).new
        DB.open @databasePath do |db|
            measurements = db.query_all "SELECT date, time, #{key} FROM measurements", as: {date: String, time: String, value: Int64 | Float64}
        end
        measurements
    end

    def cleanDb
        DB.open @databasePath do |db|
            db.exec "DROP TABLE IF EXISTS measurements"
        end
    end
end