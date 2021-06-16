# Consumption collector

## Used with:

- gosund smart plug sp1
- flashed with tasmota

## Configuration

- `url`: the url to the smart plug api
- `fields`: fields from the api which should be stored
- `intervall`: measure intervall in seconds
- `output`: file extension of the output file
- `delimiter`: delimiter for output file

## Example

1. plug in sp1.
2. used config:
```json
{
    "url": "http://192.168.43.111/cm?cmnd=status%208",
    "fields": [
        "power"
    ],
    "intervall": 1,
    "output": ".csv",
    "delimiter": ","
}
```

3. start script by calling `crystal src/main.cr` inside root directory. It will automatically create a sqlite3 database `data.db` and pass the measurements to it.
```bash
"power"
[0]
"power"
[1]
"power"
[2]
"power"
[1]
"power"
[2]
"power"
[2]
...
```

4. when ending measurement interrupt the script by pressing Ctrl+C.
5. the script will automatically safe the data by appending to the data file with configured file extension e.g. `data.csv`.
   it will use the configured delimiter to save the data.
   |csv|excel|
   |---|---|
   |![csv](https://github.com/tim0-12432/crystal-tools/blob/master/consumption-collector/doc/csv.PNG)|![xlsx](https://github.com/tim0-12432/crystal-tools/blob/master/consumption-collector/doc/xlsx.PNG)|
   ![plot](https://github.com/tim0-12432/crystal-tools/blob/master/consumption-collector/doc/graph.PNG)