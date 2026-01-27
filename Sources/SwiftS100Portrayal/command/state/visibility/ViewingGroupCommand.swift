//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct ViewingGroupCommand: VisibilityStateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        for arg in args {
            if let viewingGroup = Int(arg) {
                state.visibilityState.viewingGroups.insert(viewingGroup)
            }
        }
        
        return nil
    }
    
}
