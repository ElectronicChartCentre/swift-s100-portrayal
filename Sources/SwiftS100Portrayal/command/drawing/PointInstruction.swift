//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct PointInstruction: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    public let geometryState: GeometryState.Record
    public let transformState: TransformState.Record

    public let instructionTypePriority = 90
    
    let symbol: String
    
    init(state: PortrayalState, args: [String]) {
        visibilityState = state.visibilityState.toRecord()
        geometryState = state.geometryState.toRecord()
        transformState = state.transformState.toRecord()
        
        symbol = args.first ?? "unknown"
    }
    
}
