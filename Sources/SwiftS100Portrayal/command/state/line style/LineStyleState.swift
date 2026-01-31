//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

class LineStyleState {
    
    var dashs: [Dash] = []
    
    func consumeDashs() -> [Dash] {
        defer { dashs.removeAll() }
        return dashs
    }
    
}
