//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct SVGShapeStyle {
    
    public let strokeWidth: Double?
    public let fillOpacity: Double?
    
    static func create(_ kv: [String: String]) -> SVGShapeStyle {
        
        let strokeWidth = kv["stroke-width"].flatMap(Double.init)
        let fillOpacity = kv["fill-opacity"].flatMap(Double.init)
        
        return SVGShapeStyle(strokeWidth: strokeWidth, fillOpacity: fillOpacity)
    }
    
}
