//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct FeatureDrawingCommand: Sendable, Comparable {
    
    public let featureId: String
    public let drawingCommandId: String
    public let drawingCommand: any DrawingCommand
    public let observedParameters: [String: String]
    
    public func matches(contextParameters: [String: String]) -> Bool {
        for (_, entry) in contextParameters.enumerated() {
            if let observedValue = observedParameters[entry.key], observedValue != entry.value {
                return false
            }
        }
        return true
    }
    
    public static func < (lhs: FeatureDrawingCommand, rhs: FeatureDrawingCommand) -> Bool {
        if lhs.drawingCommand.visibilityState.displayPlaneIsOverRadar != rhs.drawingCommand.visibilityState.displayPlaneIsOverRadar {
            return !lhs.drawingCommand.visibilityState.displayPlaneIsOverRadar
        }
        
        if lhs.drawingCommand.visibilityState.drawingPriority != rhs.drawingCommand.visibilityState.drawingPriority {
            return lhs.drawingCommand.visibilityState.drawingPriority < rhs.drawingCommand.visibilityState.drawingPriority
        }

        return lhs.drawingCommand.instructionTypePriority < rhs.drawingCommand.instructionTypePriority
    }
    
    public static func == (lhs: FeatureDrawingCommand, rhs: FeatureDrawingCommand) -> Bool {
        return lhs.featureId == rhs.featureId && lhs.drawingCommandId == rhs.drawingCommandId
    }
    
}
