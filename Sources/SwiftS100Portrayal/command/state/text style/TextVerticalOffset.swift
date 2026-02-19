//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct TextVerticalOffset: TextStyleCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 1, let offset = Double(args[0]) {
            state.textStyleState.verticalOffset = offset
        }
        
        return nil
    }
    
}
