//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct LineStyle: Sendable {
    
    public let name: String
    public let intervalLength: Double
    public let pen: Pen
    public let dashs: [Dash]
    public let symbols: [LineSymbol]
    
}
