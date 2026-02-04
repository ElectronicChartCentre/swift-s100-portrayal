//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct PointInstruction: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    public let geometryState: GeometryState.Record

    public let rotationCRS: String?
    public let rotation: Double?
    
    public let instructionTypePriority = 90
    
    let symbol: String
    
    init(state: PortrayalState, args: [String]) {
        visibilityState = state.visibilityState.toRecord()
        geometryState = state.geometryState.toRecord()

        rotationCRS = state.transformState.rotationCRS
        rotation = state.transformState.rotation
        
        symbol = args.first ?? "unknown"
    }
    
}
