//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct ColorFill: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    
    public let instructionTypePriority = 50
    
    public let token: String
    public let transparency: Double
    
    init(state: PortrayalState, args: [String]) {
        self.visibilityState = state.visibilityState.toRecord()
        
        token = args[0]
        if args.count > 1 {
            transparency = Double(args[1]) ?? 0.0
        } else {
            transparency = 0.0
        }
    }
    
}
