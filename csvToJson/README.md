# CsvToJson

Quick script thrown together, there are probably a lot of things to fix up

## Use

From the base folder:

Using the provided example files:

```
cd /Users/deebayavrom/Documents/xcodeiOS/bahaiMap/csvToJson
sh
swift run CsvToJson -- bahai.csv > bahai.json 
```

Generally:
```sh
swift run CsvToJson -- [path to your csv] > [path to the file you want to create]
```

## Adjustments

You can change which columns of the CSV are exported with the variables `start` and `end` in the function `process`.
