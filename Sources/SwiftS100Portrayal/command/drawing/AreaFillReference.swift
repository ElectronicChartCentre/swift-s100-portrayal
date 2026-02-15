//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct AreaFillReference: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    public let geometryState: GeometryState.Record
    
    public let instructionTypePriority = 70
    
    public let reference: String
    
    init(state: PortrayalState, args: [String]) {
        visibilityState = state.visibilityState.toRecord()
        geometryState = state.geometryState.toRecord()
        
        reference = args[0]
    }
    
}
