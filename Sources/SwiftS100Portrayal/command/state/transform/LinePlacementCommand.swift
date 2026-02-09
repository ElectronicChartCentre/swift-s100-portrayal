//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct LinePlacementCommand: TransformCommand {
    
    static let Relative = "Relative"
    static let Absolute = "Absolute"
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count < 2 {
            return nil
        }
        
        state.transformState.linePlacementMode = args[0]
        if let linePlacementOffset = Double(args[1]) {
            state.transformState.linePlacementOffset = linePlacementOffset
        }
        if args.count > 2, let linePlacementEndOffset = Double(args[2]) {
            state.transformState.linePlacementEndOffset = linePlacementEndOffset
        }
        if args.count > 3, let linePlacementVisibleParts = Bool(args[3]) {
            state.transformState.linePlacementVisibleParts = linePlacementVisibleParts
        }
        
        return nil
    }
    
}
