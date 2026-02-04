//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct AlertReference: StateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        // not doing anythings with alerts yet.
        return nil
    }

    
}
