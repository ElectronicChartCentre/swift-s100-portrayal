//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct ScaleFactorCommand: TransformCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count < 1 {
            return nil
        }
        
        if let scaleFactor = Double(args[0]) {
            state.transformState.scaleFactor = scaleFactor
        }
        
        return nil
    }
    
}
