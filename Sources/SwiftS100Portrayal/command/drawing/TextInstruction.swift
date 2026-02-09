//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct TextInstruction: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    
    public let geometryState: GeometryState.Record
    
    public let textStyleState: TextStyleState.Record
    
    public var instructionTypePriority: Int = 0 // 100
    
    let text: String
    
    init(state: PortrayalState, args: [String]) {
        visibilityState = state.visibilityState.toRecord()
        geometryState = state.geometryState.toRecord()
        textStyleState = state.textStyleState.toRecord()
        
        text = args.first ?? ""
    }

}
