//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct AreaPlacementCommand: TransformCommand {
    
    enum AreaPlacementMode: String {
        case VisibleParts
        case Geographic
    }
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 1, let mode = AreaPlacementMode(rawValue: args[0]) {
            state.transformState.areaPlacement = mode
        } else {
            print("TODO: implement \(self.self) for args: \(args)")
        }
        
        return nil
    }
    
}
