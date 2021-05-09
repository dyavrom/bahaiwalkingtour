#!/usr/bin/env swift
import Foundation
import CSV

func process(string: String) throws {
    let csv = try! CSVReader(string: string,
                         hasHeaderRow: true)
    //let headerRow = csv.headerRow!

    var rows = [[String]]()
    let start = 1
    let end = 12
    while let row = csv.next() {
        rows.append(Array(row[start...end]))
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted


    let data = try encoder.encode(rows)
    print(String(data: data, encoding: .utf8)!)
}

func processFile(at url: URL) throws {
    let s = try String(contentsOf: url)
    try process(string: s)
}

func main() {
    guard CommandLine.arguments.count > 1 else {
        print("usage: \(CommandLine.arguments[0]) file...")
        return
    }
    for path in CommandLine.arguments[1...] {
        do {
            let u = URL(fileURLWithPath: path)
            try processFile(at: u)
        } catch {
            // print("error processing: \(path): \(error)")
        }
    }
}

main()
exit(EXIT_SUCCESS)
