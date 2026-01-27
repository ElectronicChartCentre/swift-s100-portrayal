//
//  File.swift
//  swift-s100-portrayal
//

import Foundation
import SwiftGeo

public protocol Renderer {
    
    func add(geometry: Geometry, drawingCommand: DrawingCommand)
    
}
