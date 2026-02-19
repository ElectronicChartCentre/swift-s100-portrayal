//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct FontWeight: TextStyleCommand {
    
    enum FontWeightVariant: String {
        case Light
        case Medium
        case Bold
    }
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 1, let variant = FontWeightVariant(rawValue: args[0]) {
            state.textStyleState.fontWeight = variant
        } else {
            print("TODO: implement \(self.self) for args: \(args)")
        }
        
        return nil
    }
    
}
