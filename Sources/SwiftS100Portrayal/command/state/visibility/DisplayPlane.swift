//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct DisplayPlane: VisibilityStateCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        // DisplayPlane:UnderRadar
        // DisplayPlane:OverRadar
        if args.count > 0 && args.first == "OverRadar" {
            state.visibilityState.displayPlaneIsOverRadar = true
        }
        
        return nil
    }
    
}
