//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct LineSymbol: Sendable {
    
    public let reference: String
    public let position: Double
    
    static func create(_ e: Element) -> LineSymbol? {
        guard let reference = e.attributeByKey["reference"],
              let position = e["position"].flatMap(Double.init) else {
            return nil
        }
        return LineSymbol(reference: reference, position: position)
    }
    
}
