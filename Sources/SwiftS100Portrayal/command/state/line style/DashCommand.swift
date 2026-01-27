//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct DashCommand: LineStyleStateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        // Dash:0,3.6
        if args.count < 2 {
            return nil
        }
        
        guard let start = Double(args[0]), let length = Double(args[1]) else {
            return nil
        }
        
        let dash = Dash(start: start, length: length)
        state.lineStyleState.dashs.append(dash)
        
        return nil
    }
    
}
