//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct PointInstruction: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    
    public let instructionTypePriority = 90
    
    let symbol: String
    
    init(state: PortrayalState, args: [String]) {
        visibilityState = state.visibilityState.toRecord()
        
        symbol = args.first ?? "unknown"
    }
    
}
