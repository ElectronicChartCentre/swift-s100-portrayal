//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

struct DrawingCommandCreator: Sendable {
    
    static let shared = DrawingCommandCreator()
    
    private let registry: [String: @Sendable (PortrayalState, [String]) -> DrawingCommand?]
    
    private init() {
        var registry: [String: @Sendable (PortrayalState, [String]) -> DrawingCommand?] = [:]
        
        // visibility state commands
        registry["ViewingGroup"] = ViewingGroupCommand.handle(state:args:)
        registry["DisplayPlane"] = DisplayPlane.handle(state:args:)
        registry["DrawingPriority"] = DrawingPriorityCommand.handle(state:args:)
        registry["ScaleMinimum"] = ScaleMinimumCommand.handle(state:args:)
        registry["ScaleMaximum"] = ScaleMaximumCommand.handle(state:args:)
        registry["Id"] = IdCommand.handle(state:args:)
        registry["Parent"] = ParentCommand.handle(state:args:)
        registry["Hover"] = HoverCommand.handle(state:args:)
        
        // transform
        registry["LocalOffset"] = LocalOffsetCommand.handle(state:args:)
        registry["LinePlacement"] = LinePlacementCommand.handle(state:args:)
        registry["AreaPlacement"] = AreaPlacementCommand.handle(state:args:)
        registry["AreaCRS"] = AreaCRSCommand.handle(state:args:)
        registry["Rotation"] = RotationCommand.handle(state:args:)
        registry["ScaleFactor"] = ScaleFactorCommand.handle(state:args:)

        // line style
        registry["Dash"] = DashCommand.handle(state:args:)
        registry["LineStyle"] = LineStyleCommand.handle(state:args:)

        // drawing commands
        registry["PointInstruction"] = PointInstruction.init(state:args:)
        registry["LineInstruction"] = LineInstruction.init(state:args:)
        registry["ColorFill"] = ColorFill.init(state:args:)
        
        // null instruction
        registry["NullInstruction"] = NullInstruction.init(state:args:)
        
        self.registry = registry

    }
    
    func create(def: DataExchangeFormat) -> [DrawingCommand] {
        var drawingCommands = [DrawingCommand]()
        
        let state = PortrayalState()
        for entry in def.entries {
            // dictionary instead of switch for faster lookup
            if let function = registry[entry.key] {
                if let drawingCommand = function(state, entry.arguments) {
                    drawingCommands.append(drawingCommand)
                }
            } else {
                print("TODO: unknown instruction: \(entry.key)")
            }
        }
        
        return drawingCommands
    }
    
}
