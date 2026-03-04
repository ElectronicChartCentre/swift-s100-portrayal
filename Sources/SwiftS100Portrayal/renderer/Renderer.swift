//
//  File.swift
//  swift-s100-portrayal
//

import Foundation
import SwiftGeo

public protocol Renderer {
    
    var projection: Projection { get }
    
    var screenResolution: ScreenResolution { get }
    
    func add(geometry: Geometry, drawingCommand: DrawingCommand)
    
    func output() -> RendererOutput?
    
}
