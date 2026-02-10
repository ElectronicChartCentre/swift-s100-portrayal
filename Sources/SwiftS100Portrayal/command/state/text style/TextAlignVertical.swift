//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct TextAlignVertical: TextStyleCommand {
    
    static let Top = "Top"
    static let Center = "Center"
    static let Bottom = "Bottom"
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count != 1 {
            return nil
        }
        
        state.textStyleState.textAlignVertical = args[0]
        
        return nil
    }
    
}
