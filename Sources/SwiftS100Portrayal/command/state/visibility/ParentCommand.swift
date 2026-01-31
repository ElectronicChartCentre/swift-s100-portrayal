//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct ParentCommand: VisibilityStateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        print("TODO: implement Parent")
        return nil
    }
    
}
