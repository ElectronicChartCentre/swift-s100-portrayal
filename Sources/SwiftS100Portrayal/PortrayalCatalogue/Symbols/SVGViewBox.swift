//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct SVGViewBox {
    
    public let x: Double
    public let y: Double
    public let width: Double
    public let height: Double
    
    static func create(_ def: String?) -> Self? {
        
        guard let def = def else {
            return nil
        }
        
        let parts = def.split(separator: " ").compactMap(Double.init)
        guard parts.count == 4 else { return nil }
        return SVGViewBox(x: parts[0], y: parts[1], width: parts[2], height: parts[3])
    }
    
}
