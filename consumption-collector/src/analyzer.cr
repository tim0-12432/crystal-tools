require "aquaplot"

class Analyzer
    property outputExtension : String
    property delimiter : String

    def initialize(config)
        @outputExtension = config.output
        @delimiter = config.delimiter
    end

    def exportPlot(list)
        x_data = list.map_with_index{|item, idx| idx}
        y_data = list.map{|item| item["value"]}
        line = AquaPlot::Line.new y_data
        line.show_points
        line.set_linewidth 1
        plt = AquaPlot::Plot.new line
        plt.set_title "Measurements"
        plt.show
        plt.savefig("plot.png")
        plt.close
    end

    def exportFile(list, key)
        filename = "data-#{key}.#{outputExtension.strip(".")}"
        File.write(filename, "date#{@delimiter}time#{@delimiter}#{key}\n", mode: "a")
        list.each do |item|
            content = "#{item["date"]}#{@delimiter}#{item["time"]}#{@delimiter}#{item["value"]}\n"
            File.write(filename, content, mode: "a")
        end
    end
end