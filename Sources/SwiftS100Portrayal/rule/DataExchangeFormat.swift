//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct DataExchangeFormat {
    
    let entries: [DataExchangeFormatEntry]
    
    init(_ def: String) {
        var entries: [DataExchangeFormatEntry] = []
        
        var part = ""
        var entryKey: String? = nil
        var entryArguments: [String] = []
        
        var escape = false
        for c in def {
            if escape {
                switch (c) {
                case "s":
                    part.append(";")
                case "c":
                    part.append(":")
                case "m":
                    part.append(",")
                case "a":
                    part.append("&")
                default:
                    break
                }
                escape = false
                continue
            }
            
            switch (c) {
            case "&":
                escape = true
            case ":":
                entryKey = String(part)
                part.removeAll()
                entryArguments.removeAll()
            case ",":
                entryArguments.append(String(part))
                part.removeAll()
            case ";":
                if entryKey == nil {
                    entryKey = String(part)
                } else if !part.isEmpty {
                    entryArguments.append(String(part))
                }
                part.removeAll()
                entries.append(DataExchangeFormatEntry(key: entryKey!, arguments: entryArguments))
                entryKey = nil
                entryArguments.removeAll()
            default:
                part.append(c)
            }
        }
        
        if entryKey != nil, !part.isEmpty {
            entryArguments.append(String(part))
            part.removeAll()
        }
        
        if let entryKey = entryKey {
            entries.append(DataExchangeFormatEntry(key: entryKey, arguments: entryArguments))
        }
        
        self.entries = entries
    }
    
}

struct DataExchangeFormatEntry {
    
    let key: String
    let arguments: [String]
    
}
