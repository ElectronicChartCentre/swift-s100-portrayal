//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct Pen: Sendable {
    
    public let width: Double
    public let color: String
    
    static func create(_ e: Element) -> Pen? {
        guard let width = e.attributeByKey["width"].flatMap(Double.init),
              let color = e["color"] else {
            return nil
        }
        return Pen(width: width, color: color)
    }
    
}
