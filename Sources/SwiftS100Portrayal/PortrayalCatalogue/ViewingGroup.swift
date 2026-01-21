//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct ViewingGroup {
    
    let id: String
    let description: Description
    
    static func create(_ kv: [String: String], id: String, description: Description) -> ViewingGroup? {
        return ViewingGroup(id: id, description: description)
    }

    
}
