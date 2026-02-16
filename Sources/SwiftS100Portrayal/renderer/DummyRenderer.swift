//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

import SwiftGeo

struct DummyRenderer: Renderer {
    
    func add(geometry: any SwiftGeo.Geometry, drawingCommand: any DrawingCommand) {
        // ignoring
    }
    
    func asPNGData() -> Data? {
        return nil
    }
    
}
