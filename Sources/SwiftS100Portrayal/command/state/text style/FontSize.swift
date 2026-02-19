//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct FontSize: TextStyleCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 1, let fontSize = Double(args[0]) {
            state.textStyleState.fontSize = fontSize
        } else {
            print("TODO: implement \(self.self) for args: \(args)")
        }
        
        return nil
    }
    
}
