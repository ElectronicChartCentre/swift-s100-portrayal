//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct Description {
    
    let name: String
    let description: String
    let language: String
    
    static func create(_ kv: [String: String]) -> Description? {
        guard let name = kv["name"] else {
            return nil
        }
        guard let description = kv["description"] else {
            return nil
        }
        guard let language = kv["language"] else {
            return nil
        }
        return Description(name: name, description: description, language: language)
    }
    
}
