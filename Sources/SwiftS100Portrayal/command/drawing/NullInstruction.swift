//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct NullInstruction: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    
    public let instructionTypePriority = 0
    
    init(state: PortrayalState, args: [String]) {
        visibilityState = state.visibilityState.toRecord()
    }
    
}
