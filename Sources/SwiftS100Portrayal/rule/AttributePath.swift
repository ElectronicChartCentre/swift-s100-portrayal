//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation
import SwiftS101

struct AttributePath {
    
    private let definition: String
    private let def: DataExchangeFormat
    
    init(definition: String) {
        self.definition = definition
        def = DataExchangeFormat.init(definition)
    }
    
    func resolveAttributePath(dsf: DataSetFile, record: Attributable, atcd: String) -> [String] {
        
        var node = record.attrs.rootNode
        
        for entry in def.entries {
            guard let first = entry.arguments.first, let atix = Int(first) else {
                print("ERROR: can not parse first element of \(entry.arguments) as int for atix")
                continue
            }
            
            let children = node.children(atcd: entry.key)
            if children.count < atix {
                return []
            } else {
                node = children[atix - 1]
            }
        }
        
        let children = node.children(atcd: atcd)
        if children.isEmpty {
            return []
        }

        var atvls: [String] = []
        for child in children {
            if let attr = child.attr {
                atvls.append(attr.atvl)
            }
        }
        
        return atvls
    }
    
}
