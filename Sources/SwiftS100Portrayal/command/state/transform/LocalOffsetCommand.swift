//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct LocalOffsetCommand: TransformCommand {
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        if let xmm = Double(args[0]), let ymm = Double(args[1]) {
            state.transformState.localOffsetXMM = xmm
            state.transformState.localOffsetYMM = ymm
        }
        
        return nil
    }
    
}
