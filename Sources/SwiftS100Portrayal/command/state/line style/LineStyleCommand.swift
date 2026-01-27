//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

struct LineStyleCommand: LineStyleStateCommand {
    
    let name: String
    let intervalLength: Double
    let width: Double
    let token: String
    
    static func handle(state: PortrayalState, args: [String]) -> DrawingCommand? {
        
        // LineStyle:_simple_,5.4,0.32,CHBLK
        // LineStyle:name,intervalLength,width,token[,transparency[,capStyle[,joinStyle[,offset]]]]
        
        if args.count < 4 {
            return nil
        }
        
        let name = args[0]
        let intervalLength = Double(args[1]) ?? 0
        let width = Double(args[2]) ?? 0
        let token = args[3]

        // TODO: handle with more parameters
        
        let pen = Pen(width: width, color: token)
        let dashs = state.lineStyleState.consumeDashs()
        let lineStyle = LineStyle(name: name, intervalLength: intervalLength, pen: pen, dashs: dashs, symbols: [])

        state.lineStyles.append(lineStyle)
        
        return nil
    }
    
}
