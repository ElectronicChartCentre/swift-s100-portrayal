//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct HoverCommand: VisibilityStateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        // ignoring for now
        return nil
    }
    
}
