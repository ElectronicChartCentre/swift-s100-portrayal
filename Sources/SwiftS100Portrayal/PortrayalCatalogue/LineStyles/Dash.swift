//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct Dash: Sendable {
    
    let start: Double
    let length: Double
 
    static func create(_ e: Element) -> Dash? {
        guard let start = e["start"].flatMap(Double.init),
              let length = e["length"].flatMap(Double.init) else {
            return nil
        }
        return Dash(start: start, length: length)
    }
    
}
