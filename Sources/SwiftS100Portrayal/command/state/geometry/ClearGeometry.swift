//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct ClearGeometry: GeometryCommand {

    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        state.geometryState.spatialReferences.removeAll()
        state.geometryState.augmentedGeometry = nil
        
        return nil
    }

}
