//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct RotationCommand: TransformCommand {
    
    enum RotationCRS: String {
        case GeographicCRS = "GeographicCRS"
        case PortrayalCRS = "PortrayalCRS"
        case LocalCRS = "LocalCRS"
        case LineCRS = "LineCRS"
    }
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        state.transformState.rotationCRS = args[0]
        state.transformState.rotation = Double(args[1])
        return nil
    }
    
}
