//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct FontSlant: TextStyleCommand {
    
    enum FontSlantVariant: String {
        case Upright
        case Italics
    }
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 1, let variant = FontSlantVariant(rawValue: args[0]) {
            state.textStyleState.fontSlant = variant
        } else {
            print("TODO: implement \(self.self) for args: \(args)")
        }
        
        return nil
    }
    
}
