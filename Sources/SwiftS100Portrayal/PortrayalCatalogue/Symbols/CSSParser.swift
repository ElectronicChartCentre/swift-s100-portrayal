//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct CSSParser {
    
    static func parse(bundle: Bundle, portrayalCataloguePath: String, cssFileName: String) -> CSS? {
        
        let cssFileNameWithoutSuffix = String(cssFileName.split(separator: ".")[0])
        
        guard let cssURL = bundle.url(forResource: "\(portrayalCataloguePath)/Symbols/\(cssFileNameWithoutSuffix)", withExtension: "css") else {
            return nil
        }
        
        do {
            let data = try Data.init(contentsOf: cssURL)
            guard let css = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            return parse(css: css)
        } catch {
            return nil
        }
    }
    
    static func parse(css: String) -> CSS? {
        var inDeclaration = false
        var inComment = false
        
        var entriesByClassSelector: [String: [CSS.Entry]] = [:]
        var currentClassSelector: String?
        var currentEntries: [CSS.Entry] = []
        
        var prevChar = Character("_")
        var currentString = ""
        for c in css {
            
            // comment handling separate from the rest
            if !inComment && c == "*" && prevChar == "/" {
                inComment = true
                prevChar = c
                continue
            }
            if inComment {
                if c == "/" && prevChar == "*" {
                    inComment = false
                    currentString.removeAll()
                }
                prevChar = c
                continue
            }
            
            switch (c) {
            case "\n":
                break
            case "{":
                inDeclaration = true
            case "}":
                let kv = currentString.components(separatedBy: ":")
                if kv.count == 2, let k = kv.first, let v = kv.last {
                    if let entry = CSS.createEntry(k: k, v: v) {
                        currentEntries.append(entry)
                    }
                }
                currentString = ""
                if let classSelector = currentClassSelector {
                    entriesByClassSelector[classSelector] = currentEntries
                    currentClassSelector = nil
                    currentEntries.removeAll()
                }
                inDeclaration = false
            case ";":
                let kv = currentString.components(separatedBy: ":")
                if kv.count == 2, let k = kv.first, let v = kv.last {
                    if let entry = CSS.createEntry(k: k, v: v) {
                        currentEntries.append(entry)
                    }
                }
                currentString = ""
            case " ":
                if !inDeclaration, currentString.count > 2, let dotPos = currentString.firstIndex(of: ".") {
                    currentClassSelector = String(currentString[currentString.index(after: dotPos)...])
                    currentString = ""
                }
            default:
                currentString.append(c)
            }
            prevChar = c
        }

        return CSS(entriesByClassSelector: entriesByClassSelector)
    }
    
}
