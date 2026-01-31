//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct ScaleMaximumCommand: VisibilityStateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        if let v = Int(args[0]) {
            state.visibilityState.scaleMaximum = v
        }
        return nil
    }
    
}
