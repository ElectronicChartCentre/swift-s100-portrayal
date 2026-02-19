//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct AreaCRSCommand: TransformCommand {
    
    enum AreaCRSType: String {
        case Global
        case LocalGeometry
        case GlobalGeometry
    }
        
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if args.count == 1, let areaCRS = AreaCRSCommand.AreaCRSType(rawValue: args[0]) {
            state.transformState.areaCRS = areaCRS
        } else {
            print("TODO: implement \(self.self) for args: \(args)")
        }
        
        return nil
    }
    
}
