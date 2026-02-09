//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct FontColor: TextStyleCommand {

    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count > 0 {
            state.textStyleState.fontColorToken = args[0]
        }
        
        if args.count > 1, let transparency = Double(args[1]) {
            state.textStyleState.fontColorTransparency = transparency
        }
        
        return nil
    }

}
