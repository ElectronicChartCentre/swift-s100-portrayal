//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct TextAlignHorizontal: TextStyleCommand {
    
    static let Start = "Start"
    static let Center = "Center"
    static let End = "End"

    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count != 1 {
            return nil
        }
        
        state.textStyleState.textAlignHorizontal = args[0]

        return nil
    }
    
}
