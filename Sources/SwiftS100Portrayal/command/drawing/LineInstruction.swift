//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public struct LineInstruction: DrawingCommand {
    
    public let visibilityState: VisibilityState.Record
    
    public let instructionTypePriority = 80
    
    private let lineStylesFromState: [LineStyle]
    private let lineStylesFromStateByName: [String: LineStyle]
    private let lineStyleReferences: [String]
    
    init(state: PortrayalState, args: [String]) {
        visibilityState = state.visibilityState.toRecord()
        lineStylesFromState = state.lineStyles
        
        var byName: [String: LineStyle] = [:]
        for lineStyle in lineStylesFromState {
            byName[lineStyle.name] = lineStyle
        }
        lineStylesFromStateByName = byName

        lineStyleReferences = args
    }
    
    func lineStyles(portrayalCatalogue: PortrayalCatalogue) -> [LineStyle] {
        var lineStyles: [LineStyle] = []
        for lineStyleReference in lineStyleReferences {
            if let lineStyle = lineStylesFromStateByName[lineStyleReference] {
                lineStyles.append(lineStyle)
            } else if let lineStyle = portrayalCatalogue.lineStyleByName[lineStyleReference] {
                lineStyles.append(lineStyle)
            }
        }
        return lineStyles
    }
    
}
