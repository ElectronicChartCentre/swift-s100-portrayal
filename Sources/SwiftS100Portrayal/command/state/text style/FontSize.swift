//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct FontSize: TextStyleCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if let fontSize = Double(args[0]) {
            state.textStyleState.fontSize = fontSize
        }
        
        return nil
    }
    
}
