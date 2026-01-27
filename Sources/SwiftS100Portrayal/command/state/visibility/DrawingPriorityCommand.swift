//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct DrawingPriorityCommand: VisibilityStateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        // DrawingPriority:15
        if let drawingPriority = Int(args.first ?? "") {
            state.visibilityState.drawingPriority = drawingPriority
        }
        
        return nil
    }
    
}
